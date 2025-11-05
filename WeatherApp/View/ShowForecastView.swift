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
            HStack {
                Text(data.location)
                    .font(.largeTitle)
                
                VStack {
                    HStack{
                        Text("Currently:")
                        data.icon
                    }
                    HStack{
                        Text(data.temperature)
                        Text(data.wind)
                        Text(data.windDir)
                    }
                }

            }

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
