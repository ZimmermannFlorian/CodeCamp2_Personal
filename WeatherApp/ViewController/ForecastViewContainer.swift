//
//  ForecastViewContainer.swift
//  WeatherApp
//
//  Created by florian on 27.10.25.
//
import SwiftUI;

struct ForecastDayViewContainer{
    var icon : Image;
    var temperature : String
    var weekDay : String
}

struct ForecastViewContainer {
    var location : String
    var tempureature : String
    
    var wind : String
    var windDir : String
    
    var days : [ForecastDayViewContainer]
}

//Null Container for Debug Views
var NullForecastDayViewContainer : ForecastDayViewContainer {
    ForecastDayViewContainer(icon: Image(systemName: "cloud"), temperature: "0ºC", weekDay: "Mon")
}
var NullForecastViewContainer : ForecastViewContainer {
    ForecastViewContainer(location: "Test", tempureature: "0ºC", wind: "0 km/h", windDir: "NW", days: [NullForecastDayViewContainer, NullForecastDayViewContainer, NullForecastDayViewContainer])
}
