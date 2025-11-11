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
    
    //listener
    @Published var update_toggle : Bool = false

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
    
    var searchRequester : NetworkRequest
    var cache : PersistentCache
    
    init() {
        
        //search requester
        self.searchRequester = NetworkRequest()
        self.cache = PersistentCache()
        
        // load cache (or create default)
        var last_location = "Kassel"
        if let existing = cache.data {
            last_location = existing.last_location!.location.name
        } else {
            
            // Create default state
            cache.data = PersistentCacheData(
                fav_locations: [
                    "Kassel",
                    "Frankfurt(Oder)",
                    "Uelzen",
                    "Duisburg"
                ],
                locations: [nil, nil, nil, nil],
                last_location: nil
            )
        }
        
        self.image_cache = ImageCache()
        self.currLocation = WeatherForecastController(last_location, cache.data!.last_location)
        self.location_manager = LocationManager()
        self.location_manager.locationStr = last_location
        
        //Create Location Handlers
        self.fav_Locations = []
        for i in 0...cache.data!.fav_locations.count-1 {
            fav_Locations.append(WeatherForecastController(
                cache.data!.fav_locations[i],
                cache.data!.locations[i]
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
    
        //setup location listener
        self.location_change_listener = self.location_manager.$locationStr.sink { data in
            if data != self.currLocation.location {
                self.currLocation.location = data
                self.currLocation.reload()
            }
        }
        self.location_manager.startListener()
    
        //setup search callback
        self.searchRequester.callback = searchQueryCallback
        self.cache.model = self        
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
        
        //default is loaded by image cache while loading,
        //so this is always valid
        let image = image_cache.map[forecastIcon]
        return image!
    }
    
    func data_sink_callback(data : WeatherForecast?) {
        if data != nil {
            self.data_change_callback()
        }
    }
    
    func data_change_callback() {
        self.update_toggle = true
        
        //mark for lazy update
        cache.lazy_update_persistant_data = true
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
            debugPrint("Couldn't parse provided Json as Weather Location search for \(url):\n\(error)")
            return;
        }
        
        //store data using the main thread
        OperationQueue.main.addOperation {
            debugPrint("search query")
            
            if let first = searchResults.first {
                self.addLocation_callback(first.url)
            }
        }
        
    }
    
}
