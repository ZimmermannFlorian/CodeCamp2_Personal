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
    @State var newLocation : String = ""

    var body: some View {
        VStack  {
            
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
            
            //Show Favorites list
            List(mvc.weatherViewData.fav_locations, id: \.id) { f in
                
                if f.isCurrentPosition {
                    //just create
                    ShowForecrastView(data: f)
                } else {
                    //create with destroy fav option
                    ShowForecrastView(data: f)
                        .swipeActions(content: {
                            Button(role: .destructive) {
                                mvc.removeLocation(f.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                        })
                }
                
            }
            .refreshable {
                self.mvc.model.refresh()
            }

        }
    }
    
    func toggleTemperature(){
        mvc.settings.useFahrenheit = !mvc.settings.useFahrenheit
    }
    
    func toggleSpeed() {
        mvc.settings.useMiles = !mvc.settings.useMiles
    }
 
}

#Preview {

}

