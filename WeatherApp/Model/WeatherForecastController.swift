//
//  Weather_Forecast.swift
//  WeatherApp
//
//  Created by florian on 22.10.25.
//
import Foundation
import Combine

class WeatherForecastController : ObservableObject{
    var location : String
    @Published var forecast : WeatherForecast!
    var requester : NetworkRequest
    
    //Constructor, forecast can be loaded via reload
    init(_ location: String, _ data : WeatherForecast?) {
        self.location = location
        self.forecast = data
        
        //Construct network callback
        self.requester = NetworkRequest();
        self.requester.callback = self.dataCallback
    }
    
    //loads via https a new WeatherForecast for the location
    func reload() {
        let urlString  : String = "\(WeatherAPIURL)forecast.json?key=\(WeatherAPIKey)&q=\(self.location)&days=\(NummberOfForecastDays)"
        requester.request(urlString)
    }
    
    //gets called on different threads then MAIN!
    func dataCallback(data : Data, url : String) {
        
        // Process the retrieved json
        var newForecast : WeatherForecast!
        do {
            let decoder = JSONDecoder()
            newForecast = try decoder.decode(WeatherForecast.self, from : data)
        } catch {
            //sometimes this happens :(
            print("Couldn't parse provided Json as Weather Forecast for \(self.location):\n\(error)")
            return
        }
        
        //store data using the main thread if successfully
        if newForecast != nil {
            OperationQueue.main.addOperation {
                print("update location")
                
                //update location
                self.forecast = newForecast
            }
        }
    }
    
}
