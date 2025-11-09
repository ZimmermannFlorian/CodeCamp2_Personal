//
//  Model.swift
//  WeatherApp
//
//  Created by florian on 29.10.25.
//

import Foundation
import SwiftUI
import Combine
import SwiftData

class WeatherModel : ObservableObject{
    var modelContext : ModelContext
    
    //listener
    @Published var update_toggle : Bool = false
    @Published var lazy_update_persistant_data : Bool = false
    
    // Persistent Cache
    var persistant_cache: PersistentCache
    
    //Data Fetcher
    var currLocation : WeatherForecastController
    var fav_Locations : [WeatherForecastController]
    var image_cache : ImageCache
    var location_manager : LocationManager

    //sink listener
    var curr_forecast_listener : AnyCancellable!
    var image_cache_listener : AnyCancellable!
    var location_change_listener : AnyCancellable!
    var fav_forecast_listener : [AnyCancellable]
    
    var lazy_data_save : Timer?
    var searchRequester : NetworkRequest
    
    init(_ modelcontext : ModelContext) {
        self.modelContext = modelcontext
        
        //search requester
        self.searchRequester = NetworkRequest()
        
        // fetch persistent data (all entries) sorted by last_update_epoch ascending, limited to 10
        var descriptor = FetchDescriptor<PersistentCache>(
            predicate: nil,
            sortBy: [
                SortDescriptor(\.last_update_epoch, order: .forward)
            ]
        )
        descriptor.fetchLimit = 10
        let dataRead: [PersistentCache]
        do {
            dataRead = try modelContext.fetch(descriptor)
        } catch {
            // If fetching fails, fall back to empty results
            dataRead = []
        }
        
        // load cache (pick first or create default)
        var last_location = "Kassel"
        if let existing = dataRead.last {
            self.persistant_cache = existing
            last_location = persistant_cache.last_location!.location.name
        } else {
            
            // Create default state
            self.persistant_cache = PersistentCache(
                fav_locations: [
                    "Kassel",
                    "Frankfurt(Oder)",
                    "Uelzen"
                ],
                locations: [nil, nil, nil],
                last_location: nil
            )
        }
        
        self.image_cache = ImageCache()
        self.currLocation = WeatherForecastController(last_location, persistant_cache.last_location)
        self.location_manager = LocationManager()
        self.location_manager.locationStr = last_location
        
        //Create Location Handlers
        self.fav_Locations = []
        for i in 0...persistant_cache.fav_locations.count-1 {
            fav_Locations.append(WeatherForecastController(
                persistant_cache.fav_locations[i],
                persistant_cache.locations[i]
            ))
        }
        
        //Build listeners
        self.fav_forecast_listener = []
        self.fav_Locations.forEach { f in
            let l = f.$forecast.sink(receiveValue: data_sink_callback)
            self.fav_forecast_listener.append(l)
        }
        
        self.curr_forecast_listener = self.currLocation.$forecast
            .sink(receiveValue: data_sink_callback)
        
        self.image_cache_listener = self.image_cache.$map
            .sink { data in
                self.update_toggle = true
            }
        
        self.location_change_listener = self.location_manager.$locationStr.sink { data in
            if data != self.currLocation.location {
                self.currLocation.location = data
                self.currLocation.reload()
            }
        }
        self.location_manager.startListener()
        
        //update timer, we delay it by some ms to not save at every data change
        self.lazy_data_save = Timer.scheduledTimer(withTimeInterval: 0.125, repeats: true, block: {_ in
            self.save_callback()
        })
        
        //setup search callback
        self.searchRequester.callback = searchQueryCallback
        
    }
    
    func refresh() {
        
        for p in fav_Locations {
            p.reload()
        }
        
        currLocation.reload()
    }
    
    func loadImage(_ url : String) -> Image {
        //"Load" Image
        let forecastIcon = url
        image_cache.loadImage(forecastIcon)
        
        if let image = image_cache.map[forecastIcon] {
            return image
        } else {
            // Provide a sensible fallback image to avoid crashing if the image isn't cached yet
            return Image(systemName: "photo")
        }
    }
    
    func data_sink_callback(data : WeatherForecast?) {
        if data != nil {
            self.data_change_callback()
        }
    }
    
    func data_change_callback() {
        self.update_toggle = true
        
        //mark for lazy update
        lazy_update_persistant_data = true
    }
    
    func saveCache() {
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save cache")
        }
    }
    
    func addLocation(_ name : String) {
        searchQuery(name)
    }
    
    func removeLocation(_ index : Int) {
        
        fav_forecast_listener[index].cancel()
        fav_forecast_listener.remove(at: index)
        fav_Locations.remove(at: index)
        
        data_change_callback()
    }
    
    
    func addLocation_callback(_ url : String) {
        
        let forecastC = WeatherForecastController(url, nil)
        fav_Locations.append(forecastC)
        
        //add listener
        let l = forecastC.$forecast.sink(receiveValue: data_sink_callback)
        fav_forecast_listener.append(l)
        forecastC.reload()
        
        //Notify of new data
        data_change_callback()
    }
    
    
    //gets called by a timer for lazy saving
    func save_callback() {
        
        if self.lazy_update_persistant_data {
            self.lazy_update_persistant_data = false
            
            //Create data backup
            let newData = PersistentCache(
                fav_locations: [],
                locations: [],
                last_location: nil
            )
            newData.last_location = self.currLocation.forecast
            for f in self.fav_Locations {
                newData.fav_locations.append(f.location)
                newData.locations.append(f.forecast)
                
            }
            
            //remove old & add new & invoce save data
            do {
                try self.modelContext.delete(model: PersistentCache.self)
                self.modelContext.insert(newData)
                try self.modelContext.save()
            } catch {
                print("Failed to save persistent cache: \(error)")
            }
        }
        
    }
    
    
    func searchQuery(_ query : String) {
        let urlString  : String = "\(WeatherAPIURL)search.json?key=\(WeatherAPIKey)&q=\(query)"
        searchRequester.request(urlString)
    }
    
    func searchQueryCallback(data : Data, url : String) {
        
        // Process the retrieved json
        var searchResults = [WeatherLocationSearch]()
        do {
            let decoder = JSONDecoder()
            searchResults = try decoder.decode([WeatherLocationSearch].self, from : data)
        } catch {
            print("Couldn't parse provided Json as Weather Forecast for \(url):\n\(error)")
            return;
        }
        
        //store data using the main thread
        OperationQueue.main.addOperation {
            print("search query")
            
            if let first = searchResults.first {
                self.addLocation_callback(first.url)
            }
        }
        
    }
    
}
