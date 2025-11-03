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
            HStack {
                Text(data.location).font(Font.headline)
            }
            HStack{
                data.icon
                Text(data.temperature)
                Text(data.wind)
            }
        }.border(Color.black)
    }
}

#Preview {
    ShowForecrastPreviewView(data : NullForecastViewContainer)
    ShowForecrastPreviewView(data : NullForecastViewContainer)
}
