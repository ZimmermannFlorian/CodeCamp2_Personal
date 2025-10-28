//
//  MainView.swift
//  WeatherApp
//
//  Created by florian on 28.10.25.
//

import SwiftUI

struct MainView : View {
    @ObservedObject var mvc : MV_Controller
    
    var body: some View {
        VStack  {
            ShowForecastView(data: mvc.curr_forcast_view_container)
        }
    }
}
