//
//  MV_Controller.swift
//  WeatherApp
//
//  Created by florian on 27.10.25.
//
import SwiftUI
import Foundation
import Combine

class MV_Controller : ObservableObject {
    
    private var curr_forcecast_listener : AnyCancellable!
    private var image_cache_listener : AnyCancellable!

    init(currLocation: WeatherForecastController, imgCache : ImageCache) {
        self.currLocation = currLocation
        self.image_cache = imgCache
        self.curr_forcecast_listener = self.currLocation.$forecast
            .sink { data in
                if data != nil {
                    self.curr_forcast_view_container = self.construct_forecastview_container(data.unsafelyUnwrapped)
                }
            }
        
        self.image_cache_listener = self.image_cache.$map
            .sink { data in
                //schedule refresh, so it runs AFTER the value actually changed
                OperationQueue.main.addOperation {
                    self.refresh_output()
                }
        }
    }
    
    @ObservedObject var image_cache : ImageCache
    @ObservedObject var currLocation : WeatherForecastController
    @Published var curr_forcast_view_container = NullForecastViewContainer

    //update data
    func refresh_data() {
        currLocation.reload()
    }
    
    func refresh_output() {
        
        if currLocation.forecast != nil {
            curr_forcast_view_container = construct_forecastview_container(currLocation.forecast)
        }
        
    }
    
    //conversion functions
    func construct_forecastview_container(_ input : WheatherForecast) -> ForecastViewContainer {
        return ForecastViewContainer (
            location: input.location.name,
            tempureature: getTemperature(input.current.temp_c),
            wind: getWindSpeed(input.current.wind_kph),
            windDir: input.current.wind_dir,
            days: construct_forecastdayview_container(input)
        )
    }
    
    func construct_forecastdayview_container(_ input : WheatherForecast) -> [ForecastDayViewContainer] {
        var out : [ForecastDayViewContainer] = [];
        
        for day in input.forecast.forecastday {
            
            //"Load" Image
            let forecastIcon = day.day.condition.icon
            image_cache.loadImage(forecastIcon)
            
            out.append(
                
                //construct single day
                ForecastDayViewContainer(
                    icon: image_cache.map[forecastIcon]!,
                    temperature: getTemperature(day.day.avgtemp_c),
                    weekDay: getWeekday(day.date_epoch)
                )
                
            )
        }
        return out
    }
    
    func getWindSpeed(_ wind_kph : Double) -> String {
        let wind_speed = round(wind_kph * 10.0) / 10.0
        return "\(wind_speed)km/h"
    }
    
    func getTemperature(_ temp : Double) -> String {
        return "\(round(temp * 10.0) / 10.0)ºC"
    }
    
    func getDate(_ unixTime : Int) -> String {
        let formatter = DateFormatter()
        let date = Date(timeIntervalSince1970: TimeInterval(unixTime))
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    func getWeekday(_ unixTime : Int) -> String {
        let formatter = DateFormatter()
        let date = Date(timeIntervalSince1970: TimeInterval(unixTime))
        return formatter.weekdaySymbols[Calendar.current.component(.weekday, from: date) - 1]
    }
}
