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
