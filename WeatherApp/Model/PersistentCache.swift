//
//  PersistentCache.swift
//  WeatherApp
//
//  Created by florian on 29.10.25.
//

import SwiftData
import Foundation

@Model
class PersistentCacheData {
    var last_update_epoch : Double
    var last_location : WeatherForecast?
    
    var fav_locations : [String]
    var locations : [WeatherForecast?]
        
    init(fav_locations: [String], locations: [WeatherForecast?], last_location: WeatherForecast?) {
        self.fav_locations = fav_locations
        self.locations = locations
        self.last_location = last_location
        self.last_update_epoch = Date().timeIntervalSince1970
    }
}

class PersistentCache {
    var data : PersistentCacheData?
    
    var model : WeatherModel?
    var modelContext : ModelContext
    var sharedModelContainer : ModelContainer
    var lazy_update_persistant_data : Bool = false
    var lazy_data_save : Timer?

    
    init() {
        //Create Initial Model container for persistant cache
        do {
            self.sharedModelContainer = try ModelContainer(for: PersistentCacheData.self)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        
        self.modelContext = self.sharedModelContainer.mainContext
        
        // fetch persistent data (all entries) sorted by last_update_epoch ascending, limited to 10
        var descriptor = FetchDescriptor<PersistentCacheData>(
            predicate: nil,
            sortBy: [
                SortDescriptor(\.last_update_epoch, order: .forward)
            ]
        )
        descriptor.fetchLimit = 10
        let dataRead: [PersistentCacheData]
        do {
            dataRead = try modelContext.fetch(descriptor)
        } catch {
            // If fetching fails, fall back to empty results
            dataRead = []
        }
        
        // load cache (pick first or create default)
        var last_location = "Kassel"
        if let existing = dataRead.last {
            self.data = existing
        }
        
        //update timer, we delay it by some ms to not save at every data change
        self.lazy_data_save = Timer.scheduledTimer(withTimeInterval: 0.125,
                                                   repeats: true, block: self.save_callback)
    }
    
    
    //gets called by a timer for lazy saving
    func save_callback(_ time : Timer) {
        
        if self.lazy_update_persistant_data && self.model != nil {
            self.lazy_update_persistant_data = false
            
            //Create data backup
            let newData = PersistentCacheData(
                fav_locations: [],
                locations: [],
                last_location: nil
            )
            newData.last_location = self.model!.currLocation.forecast
            for f in self.model!.fav_Locations {
                newData.fav_locations.append(f.location)
                newData.locations.append(f.forecast)
            }
            
            //remove old & add new & start saving data
            do {
                try self.modelContext.delete(model: PersistentCacheData.self)
                self.modelContext.insert(newData)
                try self.modelContext.save()
            } catch {
                debugPrint("Failed to save persistent cache: \(error)")
            }
        }
        
    }
    
}
