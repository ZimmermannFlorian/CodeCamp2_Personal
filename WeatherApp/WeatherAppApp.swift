//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by florian on 22.10.25.
//

import SwiftUI
import SwiftData

@main
struct WeatherAppApp: App {
    init() {
        
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        
    }()
    
    var view : MainView {
        return MainView(mvc: modelview_controller)
    }
    
    @State var curr_location = WeatherForecastController("Medebach")
    @State var image_cache = ImageCache()
    var modelview_controller : MV_Controller {
        return MV_Controller(currLocation: curr_location, imgCache: image_cache)
    }
    
    //build scene
    var body: some Scene {
        modelview_controller.refresh_data()
        return WindowGroup {
            view
        }
        .modelContainer(sharedModelContainer)
    }
}
