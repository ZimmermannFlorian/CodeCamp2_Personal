//
//  ForecastViewContainer.swift
//  WeatherApp
//
//  Created by florian on 27.10.25.
//
import SwiftUI
import Combine

struct WeatherViewContainer: Identifiable {
    var id = UUID()

    var current_weather: ForecastViewContainer
    var fav_locations: [ForecastViewContainer]
}

struct ForecastDayViewContainer : Identifiable{
    var id = UUID()
    
    var icon : Image;
    var temperature : String
    var weekDay : String
}

struct ForecastViewContainer : Identifiable, Equatable{
    static func == (lhs: ForecastViewContainer, rhs: ForecastViewContainer) -> Bool {
        return lhs.id == rhs.id
    }
    
    var showCurrently : Bool
    
    var location : String
    var temperature : String
    
    var wind : String
    var windDir : String
    
    var icon : Image
    var days : [ForecastDayViewContainer]
    
    var id = UUID()
}

//Null Container for Debug Views
var NullForecastDayViewContainer : ForecastDayViewContainer {
    ForecastDayViewContainer(icon: Image(systemName: "cloud"), temperature: "0ºC", weekDay: "Mon")
}
var NullForecastViewContainer : ForecastViewContainer {
    ForecastViewContainer(showCurrently: true, location: "Test", temperature: "0ºC", wind: "0 km/h", windDir: "NW", icon: Image(systemName: "cloud"), days: [NullForecastDayViewContainer, NullForecastDayViewContainer, NullForecastDayViewContainer])
}

var NullWeatherViewContainer : WeatherViewContainer{
    WeatherViewContainer(
        current_weather : NullForecastViewContainer,
        fav_locations: [NullForecastViewContainer]
    )
}

