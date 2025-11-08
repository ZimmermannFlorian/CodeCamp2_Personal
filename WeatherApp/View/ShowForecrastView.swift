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
            
            //are we are running on outdated data?
            if data.showCurrently {
                VStack {
                    HStack {
                        Text(data.location)
                            .font(Font.largeTitle)
                            .scaledToFit()
                        
                        if data.isCurrentPosition {
                            Image(systemName: "location.app")
                                .imageScale(.large)
                        }
                        
                        Spacer(minLength: 0.7)

                        data.icon
                    }
                    
                    HStack {
                        Text(data.temperature)
                        Text(data.wind)
                        Text(data.windDir)
                    }
                }
            } else {
                Text(data.location)
                    .font(Font.largeTitle)
                    .scaledToFit()
            }
            
            
            HStack {
                ForEach(Array(data.days.enumerated()), id: \.offset){ _, day in
                    ShowForecastDayView(data: day)
                }
            }.position(x: 100, y:50)

        }
        
    }
}

#Preview {
    ShowForecrastView(data : NullForecastViewContainer)
    ShowForecrastView(data : NullForecastViewContainer)
}
