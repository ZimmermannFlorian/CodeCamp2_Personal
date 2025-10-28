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
    @Published var forecast : WheatherForecast!
    
    //Constructor, forecast can be loaded via reload
    init(_ location: String) {
        self.location = location
    }
    
    //loads via https a new WeatherForecast for the location
    func reload() {
        let urlString  : String = "\(WeatherAPIURL)forecast.json?key=\(WeatherAPIKey)&q=\(self.location)&days=\(NummberOfForecastDays)"
        
        if let url = URL(string : urlString) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    // "Handle" the error
                    fatalError("Error: \(error.localizedDescription)")
                } else if let data = data {
                    
                    // Process the retrieved json
                    var newForecast : WheatherForecast!
                    do {
                        let decoder = JSONDecoder()
                        newForecast = try decoder.decode(WheatherForecast.self, from : data)
                    } catch {
                        fatalError("Couldn't parse provided Json as Weather Forecast for \(self.location):\n\(error)")
                    }
                    
                    //store data using the main thread
                    OperationQueue.main.addOperation {
                        print("update location")
                        
                        //update location
                        self.forecast = newForecast
                    }
                }
            }
            task.resume()
            
        //Error during url creation
        } else {
            fatalError("Error during url creation")
        }
        

    }
    
}
