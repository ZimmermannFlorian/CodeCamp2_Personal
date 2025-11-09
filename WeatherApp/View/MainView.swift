//
//  MainView.swift
//  WeatherApp
//
//  Created by florian on 28.10.25.
//

import SwiftUI
import Combine

struct MainView : View {
    @ObservedObject var mvc : MV_Controller

    var body: some View {
        VStack  {
            
            Headerbar(mvc: mvc)
            
            LocationList(mvc: mvc)

        }
    }
 
}

#Preview {

}

