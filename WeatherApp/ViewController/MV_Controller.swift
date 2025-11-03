//
//  MV_Controller.swift
//  WeatherApp
//
//  Created by florian on 27.10.25.
//
import SwiftUI
import Foundation
import Combine

class MV_Controller : ObservableObject{
    var model: WeatherModel
    @Published var weatherViewData : WeatherViewContainer
    var settings : MVC_Settings

    private var update_timer : Timer!
    private var update_gui_timer : Timer!
    private var model_listener : Cancellable!

    init(model : WeatherModel, settings : MVC_Settings) {
        self.model = model
        self.settings = settings
        
        //Set to null before loading
        self.weatherViewData = NullWeatherViewContainer
        
        //update timer
        self.update_timer = Timer.scheduledTimer(withTimeInterval: UpdateIntervalSeconds, repeats: true, block: { _ in
            self.model.refresh()
        })
        self.update_timer.tolerance = 0.5
        
        self.update_gui_timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true, block: { _ in
            self.refresh_output_delayed()
        })
        update_gui_timer.tolerance = 0.5
        
        self.model_listener = model.$update_toggle.sink(receiveValue:{ v in
            self.refresh_output_delayed()
        })
        
        //build basic structure
        self.model.refresh()
        self.refresh_output()
    }
    
    //gui actions
    func refresh_output() {
        
        if model.currLocation.forecast != nil {
            weatherViewData.current_weather = construct_forecastview_container(model.currLocation.forecast)
        }
        
        weatherViewData.fav_locations.removeAll()
        for p in model.fav_Locations {
            if p.forecast != nil {
                weatherViewData.fav_locations.append(construct_forecastview_container(p.forecast.unsafelyUnwrapped))
            } else {
                weatherViewData.fav_locations.append(NullForecastViewContainer)
            }
        }
        
    }
    
    
    func addLocation(_ name : String) {
        model.addLocation(name)
    }
    
    func removeLocation(_ id : UUID) {
        
        var index = 0
        for i in 0..<weatherViewData.fav_locations.count {
            if(weatherViewData.fav_locations[i].id == id) {
                index = i
                break
            }
        }
        
        model.removeLocation(index)
    }
    
    
    //update data
    func refresh_output_delayed() {
        OperationQueue.main.addOperation {
            self.refresh_output()
        }
    }
    
    //conversion functions
    func construct_forecastview_container(_ input : WeatherForecast) -> ForecastViewContainer {
        return ForecastViewContainer (
            location: input.location.name,
            temperature: getTemperature(input.current.temp_c),
            wind: getWindSpeed(input.current.wind_kph),
            windDir: input.current.wind_dir,
            icon : model.loadImage(input.current.condition.icon),
            days: construct_forecastdayview_container(input)
        )
    }
    
    func construct_forecastdayview_container(_ input : WeatherForecast) -> [ForecastDayViewContainer] {
        var out : [ForecastDayViewContainer] = [];
        
        var first = true
        for day in input.forecast.forecastday {
            
            //skip todays forecast
            if first {
                first = false
            } else {
                out.append(
                    
                    //construct single day
                    ForecastDayViewContainer(
                        icon: model.loadImage(day.day.condition.icon),
                        temperature: getTemperature(day.day.avgtemp_c),
                        weekDay: getWeekday(day.date_epoch)
                    )
                    
                )
            }
            
        }
        return out
    }
    
    func getWindSpeed(_ wind_kph : Double) -> String {
        
        if settings.useMiles {
            return "\(round(wind_kph * 0.621371 * 10.0) / 10.0)mi/h"
        }
        
        return "\(round(wind_kph * 10.0) / 10.0)km/h"
    }
    
    func getTemperature(_ temp : Double) -> String {
        
        if settings.useFahrenheit {
            return "\(round(temp * (9.0 / 5.0) + 32.0))ºF"
        }
        
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
