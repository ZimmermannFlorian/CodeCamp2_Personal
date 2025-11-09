//
//  LocationList.swift
//  WeatherApp
//
//  Created by florian on 09.11.25.
//

import SwiftUI

struct LocationList : View {
    @ObservedObject var mvc : MV_Controller
    
    var body: some View {
        
        //Show Locations list
        List(mvc.weatherViewData.locations_array, id: \.id) { f in
            
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
