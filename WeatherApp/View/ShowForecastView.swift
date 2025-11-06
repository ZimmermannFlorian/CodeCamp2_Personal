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
            //are we are running on outdated data?
            if data.showCurrently {
                HStack {
                    Text(data.location)
                        .font(.largeTitle)
                        .scaledToFit()
                    
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
            } else {
                Text(data.location)
                    .font(.largeTitle)
                    .scaledToFit()
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
