//
//  ShowForecastDay.swift
//  WeatherApp
//
//  Created by florian on 27.10.25.
//

import SwiftUI

struct ShowForecrastPreviewView : View {
    var data : ForecastViewContainer
    
    var body: some View {
        
        VStack {
            VStack {
                HStack {
                    Text(data.location)
                        .font(Font.largeTitle)
                        .scaledToFit()
                    Spacer(minLength: 0.7)
                    data.icon
                }
                
                HStack {
                    Text(data.temperature)
                    Text(data.wind)
                }
            }
            
            HStack {
                ForEach(Array(data.days.enumerated()), id: \.offset){ _, day in
                    ShowForecastDayView(data: day)
                        .padding()
                }
            }

        }
        
    }
}

#Preview {
    ShowForecrastPreviewView(data : NullForecastViewContainer)
    ShowForecrastPreviewView(data : NullForecastViewContainer)
}
