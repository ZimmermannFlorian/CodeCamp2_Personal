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
            ShowForecastView(data: mvc.weatherViewData.current_weather)
            
            List(mvc.weatherViewData.fav_locations, id: \.id) { f in
                
                ShowForecrastPreviewView(data: f)
                    .swipeActions(content: {
                        Button(role: .destructive) {
                            mvc.removeLocation(f.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    })

            }.refreshable {
                self.mvc.model.refresh()
            }

            HStack {
                TextField("Add Location", text: $newLocation)
                Button("+", action: {
                    mvc.addLocation(newLocation)
                })
            }
            Button("Toggle Mode", action: toggleSettings)
        }
    }
    
    func toggleSettings(){
        mvc.settings.useFahrenheit = !mvc.settings.useFahrenheit
        mvc.settings.useMiles = !mvc.settings.useMiles
    }
    
}

#Preview {

}

