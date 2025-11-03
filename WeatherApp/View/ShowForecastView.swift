//
//  ShowForecast.swift
//  WeatherApp
//
//  Created by florian on 27.10.25.
//

import SwiftUI
import Combine

struct ShowForecastView : View {
    var data : ForecastViewContainer
    
    var body: some View {
        VStack  {
            Text(data.location)
                .font(.largeTitle)
                .padding()
            
            Text("Currently:")
            data.icon
            HStack {
                Text(data.temperature)
                Text(data.wind)
                Text(data.windDir)
            }
            .padding()
            
            Text("Weather Trend:")
            HStack {
                ForEach(Array(data.days.enumerated()), id: \.offset) { _, day in
                    ShowForecastDayView(data: day)
                        .padding()
                }
            }
        }
    }
}

#Preview {
    ShowForecastView(data : NullForecastViewContainer)
}
