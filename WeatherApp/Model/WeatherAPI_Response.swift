//
//  WeatherAPI_Response.swift
//  WeatherApp
//
//  Created by florian on 22.10.25.
//
import Foundation

struct WeatherLocation : Hashable, Codable {
    var name: String
    var region: String
    var country: String
    var lat : Double
    var lon : Double
    var tz_id: String
    var localtime_epoch: Int
    var localtime: String
}

struct WeatherCondition : Hashable, Codable {
    var text : String
    var icon : String
    var code : Int
}

struct WeatherHour : Hashable, Codable {
    var time_epoch : Int
    var temp_c : Double
    var is_day : Int
    
    var condition : WeatherCondition
    
    var wind_kph : Double
    var wind_degree : Int
    var wind_dir : String
    
    var pressure_mb : Double
    var precip_mm : Double
    var humidity : Int
    var cloud : Int
    
    var feelslike_c : Double
    var windchill_c : Double
    var heatindex_c : Double
    
    var dewpoint_c : Double
    var vis_km : Double
    
    var uv : Double
    var gust_kph : Double
}

struct WeatherAstro : Hashable, Codable {
    var sunrise : String
    var sunset : String
    var moonrise : String
    var moonset : String
    var moon_phase : String
    var moon_illumination : Int
    var is_moon_up : Int
    var is_sun_up : Int
}

struct WeatherAVG : Hashable, Codable {
    var maxtemp_c: Double
    var mintemp_c: Double
    var avgtemp_c: Double
    var maxwind_kph: Double
    
    var totalprecip_mm: Double
    var totalsnow_cm: Double
    var avgvis_km: Double
    
    var avghumidity: Int
    var daily_will_it_rain: Int
    var daily_chance_of_rain: Int
    var daily_will_it_snow: Int
    var daily_chance_of_snow: Int
    var condition : WeatherCondition
    var uv : Double
}

struct WeatherDay : Hashable, Codable {
    var date_epoch : Int
    
    var day : WeatherAVG
    var astro : WeatherAstro
    var hour : [WeatherHour]
}

struct WeatherCurrent : Hashable, Codable{
    var last_updated_epoch : Int
    var temp_c : Double
    var is_day : Int
    
    var condition : WeatherCondition
    
    var wind_kph : Double
    var wind_degree : Int
    var wind_dir : String
    var humidity : Int
}

struct WeatherForecastHelper : Hashable, Codable {
    var forecastday : [WeatherDay]
}

struct WeatherForecast : Hashable, Codable {
    var location : WeatherLocation
    var current : WeatherCurrent
    var forecast : WeatherForecastHelper
}

struct WeatherLocationSearch : Hashable, Codable {
    var id : Int
    var name : String
    var region : String
    var country : String
    var lat : Double
    var lon : Double
    var url : String
}

