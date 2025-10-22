//
//  Weather_Forecast.swift
//  WeatherApp
//
//  Created by florian on 22.10.25.
//
import Foundation

class Weather_ForecastController{
    var location : String
    var forecast : WheatherForecast!
    init(location: String) {
        self.location = location
    }
    
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
                        self.forecast = newForecast
                    }
                }
            }
            task.resume()
        }
        

    }
    
}
