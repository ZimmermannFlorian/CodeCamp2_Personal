//
//  Headerbar.swift
//  WeatherApp
//
//  Created by florian on 09.11.25.
//

import SwiftUI

struct Headerbar : View {
    @ObservedObject var mvc : MV_Controller
    @State var newLocation : String = ""
    
    var body: some View {
        VStack {
            HStack {
                Spacer(minLength: 0.05)
                
                Button("+", action: {
                    mvc.addLocation(newLocation)
                })
                
                TextField("Add Location", text: $newLocation)
                    .frame(width: 0.75 * UIScreen.main.bounds.width)
                    .fixedSize()

                //Settings
                Button(action: toggleTemperature) {
                    if  mvc.settings.useFahrenheit {
                        Image(systemName: "degreesign.celsius")
                    } else {
                        Image(systemName: "degreesign.fahrenheit")
                    }
                }
                
                Button(action: toggleSpeed) {
                    if  mvc.settings.useMiles {
                        Text("km/h")
                    } else {
                        Text("mi/h")
                    }
                }
                
                Spacer(minLength: 0.05)
            }
        }.transition(.slide)
    }
    
    func toggleTemperature(){
        mvc.settings.useFahrenheit = !mvc.settings.useFahrenheit
        mvc.refresh_output_delayed()
    }
    
    func toggleSpeed() {
        mvc.settings.useMiles = !mvc.settings.useMiles
        mvc.refresh_output_delayed()
    }
}
