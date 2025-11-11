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
    var settings : MVC_Settings
    @Published var weatherViewData : WeatherViewContainer

    private var update_timer : Timer!
    private var model_listener : Cancellable!
    
    init(model : WeatherModel) {
        self.model = model
        self.settings = MVC_Settings()
        
        //Set to null before loading
        self.weatherViewData = NullWeatherViewContainer
        
        //update timer
        self.update_timer = Timer.scheduledTimer(withTimeInterval: UpdateIntervalSeconds, repeats: true, block: { _ in
            self.model.refresh()
        })
        self.update_timer.tolerance = 0.5
        
        self.model_listener = model.$update_toggle.sink(receiveValue:{ _ in
            self.refresh_output_delayed()
        })
        
        //build basic structure
        self.model.refresh()
        self.refresh_output()
    }
    
    //gui actions
    func refresh_output() {
        weatherViewData.locations_array.removeAll()

        if model.currLocation.forecast != nil {
            weatherViewData.locations_array.append(construct_forecastview_container(
                model.currLocation.forecast, isCurrentPosition: true))
        }
        
        for p in model.fav_Locations {
            if p.forecast != nil {
                weatherViewData.locations_array.append(construct_forecastview_container(
                    p.forecast.unsafelyUnwrapped, isCurrentPosition: false))
            } else {
                weatherViewData.locations_array.append(NullForecastViewContainer)
            }
        }
        
    }
    
    
    func addLocation(_ name : String) {
        model.addLocation(name)
    }
    
    func removeLocation(_ id : UUID) {
        var found = false
        var index = 0
        for i in 1..<weatherViewData.locations_array.count {
            if(weatherViewData.locations_array[i].id == id) {
                index = i
                found = true
                break
            }
        }
        
        if found {
            //everything is offset by 1 (currentlocation is 0)
            model.removeLocation(index - 1)
        }
    }
    
    
    //update data
    func refresh_output_delayed() {
        OperationQueue.main.addOperation {
            self.refresh_output()
        }
    }
    
    //conversion functions
    func construct_forecastview_container(_ input : WeatherForecast, isCurrentPosition : Bool) -> ForecastViewContainer {
        
        //process raw data for presenting
        return ForecastViewContainer (
            showCurrently: isToday(input.current.last_updated_epoch),
            isCurrentPosition : isCurrentPosition,
            location: getLocationName(input.location),
            temperature: getTemperature(input.current.temp_c),
            humidity: getHumidity(input.current.humidity),
            wind: getWindSpeed(input.current.wind_kph),
            windDir: input.current.wind_dir,
            icon : model.loadImage(input.current.condition.icon),
            days: construct_forecastdayview_container(input)
        )
    }
    
    func construct_forecastdayview_container(_ input : WeatherForecast) -> [ForecastDayViewContainer] {
        var out : [ForecastDayViewContainer] = [];
        
        for day in input.forecast.forecastday {
            
            out.append(
                
                //construct single day
                ForecastDayViewContainer(
                    icon: model.loadImage(day.day.condition.icon),
                    temperature: getTemperature(day.day.avgtemp_c),
                    weekDay: getWeekday(day.date_epoch)
                )
                
            )
            
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
    
    func getHumidity(_ humidity : Int) -> String {
        return "\(humidity)%";
    }
    
    func getLocationName(_ loc : WeatherLocation) -> String{
        
        if loc.name == loc.region {
            return loc.name
        }
        
        //not every place has a region
        if loc.region == "" && loc.country != "" {
            return "\(loc.name) (\(loc.country))"
        } else if loc.region == "" {
            return "\(loc.name)"
        }
        
        return "\(loc.name) (\(loc.region))"
    }
    
    func isToday(_ unixTime : Int) -> Bool {
        let date = Date(timeIntervalSince1970: TimeInterval(unixTime))
        let currDate = Date.now
        
        return Calendar.current.isDate(date, inSameDayAs: currDate)
    }
    
    func getDate(_ unixTime : Int) -> String {
        let formatter = DateFormatter()
        let date = Date(timeIntervalSince1970: TimeInterval(unixTime))
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    func getWeekday(_ unixTime : Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unixTime))
        let currDate = Date.now
        
        //Check that the data is alligning with today / show as past date if past
        if Calendar.current.isDate(date, inSameDayAs: currDate) {
            return "Today"
        } else if unixTime < Int(currDate.timeIntervalSince1970) {
            return getDate(unixTime)
        }
        
        //print weekday for future dates
        let formatter = DateFormatter()
        return formatter.weekdaySymbols[Calendar.current.component(.weekday, from: date) - 1]
    }
    
}
