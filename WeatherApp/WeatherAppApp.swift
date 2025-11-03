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
        do {
            return try ModelContainer(for: PersistentCache.self)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var view : MainView {
        return MainView(mvc: modelview_controller)
    }
    
    var settings = MVC_Settings()
    var modelview_controller : MV_Controller {
        return MV_Controller(model : model, settings : settings)
    }
    
    var model : WeatherModel {
        return WeatherModel(sharedModelContainer.mainContext)
    }
    
    //build scene
    var body: some Scene {
        return WindowGroup {
            view
        }
        .modelContainer(sharedModelContainer)
    }
}
