//
//  ShowForecastDay.swift
//  WeatherApp
//
//  Created by florian on 27.10.25.
//

import SwiftUI

struct ShowForecastDayView : View {
    var data : ForecastDayViewContainer
    
    var body: some View {
        VStack {
            HStack  {
                data.icon
            }
            HStack {
                Text(data.temperature)
            }
            Text(data.weekDay)
        }
    }
}

#Preview {
    ShowForecastDayView(data : NullForecastDayViewContainer)
}
