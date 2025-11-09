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
    
    //Create Initial Model container for persistant cache
    var sharedModelContainer: ModelContainer = {
        
        do {
            return try ModelContainer(for: PersistentCache.self)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        
    }()
    
    //Create MVC
    var model : WeatherModel {
        return WeatherModel(sharedModelContainer.mainContext)
    }
    var modelview_controller : MV_Controller {
        return MV_Controller(model : model)
    }
    var view : MainView {
        return MainView(mvc: modelview_controller)
    }
    
    //build scene
    var body: some Scene {
        return WindowGroup {
            view
        }
    }
}
