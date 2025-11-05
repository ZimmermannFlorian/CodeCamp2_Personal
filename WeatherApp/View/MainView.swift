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
    @State var showHeader = true
    @State var showFooter = false

    var body: some View {
        VStack  {
            
            //show current weather @ current location header
            if showHeader {
                ShowForecastView(data: mvc.weatherViewData.current_weather)
                    .transition(.slide)
            }
            
            if showFooter {
                VStack {
                    HStack {
                        TextField("Add Location", text: $newLocation)
                        Button("+", action: {
                            mvc.addLocation(newLocation)
                        })
                    }
                    Button("Toggle Mode", action: toggleSettings)
                }.transition(.slide)
            }
            
            //Show Favorites list
            List(mvc.weatherViewData.fav_locations, id: \.id) { f in
                ShowForecrastPreviewView(data: f)
                    .swipeActions(content: {
                        Button(role: .destructive) {
                            mvc.removeLocation(f.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                    })
            }
            .onScrollGeometryChange(for: Bool.self) { geometry in

                //Delay so we do not modify state during view update
                OperationQueue.main.addOperation {
                    
                    //the show & not show point need to be seperated by a margin
                    //to not cause a flickering effect at the transition point
                    if geometry.contentOffset.y > 200 {
                        showHeader = false
                    } else if geometry.contentOffset.y < 100 {
                        showHeader = true
                    }
                    
                    //footer for last x pixels
                    showFooter = !showHeader
                    
                }

                return true as Bool
            } action: { oldValue, newValue in
                
            }
            .refreshable {
                self.mvc.model.refresh()
            }

        }
    }
    
    func toggleSettings(){
        mvc.settings.useFahrenheit = !mvc.settings.useFahrenheit
        mvc.settings.useMiles = !mvc.settings.useMiles
    }
 
}

#Preview {

}

