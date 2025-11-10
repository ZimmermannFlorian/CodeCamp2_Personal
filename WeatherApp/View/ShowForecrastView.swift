//
//  ShowForecastDay.swift
//  WeatherApp
//
//  Created by florian on 27.10.25.
//

import SwiftUI

struct ShowForecrastView : View {
    var data : ForecastViewContainer
    
    var body: some View {
        VStack {
            if data.isCurrentPosition {
                Text("Current Location:");
            }
            
            VStack {
                
                //are we are running on valid data?
                if data.showCurrently {
                    VStack {
                        
                        HStack {
                            Text(data.location)
                                .font(Font.largeTitle)
                            
                            Spacer(minLength: 0.7)
                            
                            data.icon
                        }
                        
                        HStack {
                            Text(data.temperature)
                            Text(data.humidity)
                            Text(data.wind)
                            Text(data.windDir)
                        }
                        
                    }
                    
                //outdated data, just how the location name
                } else {
                    Text(data.location)
                        .font(Font.largeTitle)
                }
                
                
                HStack {
                    ForEach(Array(data.days.enumerated()), id: \.offset){ _, day in
                        ShowForecastDayView(data: day)
                    }
                }.position(x: 100, y:50)
                
            }
            
        }
    }
}

#Preview {
    ShowForecrastView(data : NullForecastViewContainer)
    ShowForecrastView(data : NullForecastViewContainer)
}
