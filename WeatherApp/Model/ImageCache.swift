//
//  ImageCache.swift
//  WeatherApp
//
//  Created by florian on 28.10.25.
//
import SwiftUI
import Combine

class ImageCache : ObservableObject{
    @Published var map: [String: Image] = [:]
    
    init() {
    }
    
    func loadImage(_ url_string : String) {
        
        //Already loaded?
        if map.contains(where: { (key, value) in key == url_string }) {
            return
        }
        
        //Load Placeholder
        map[url_string] = Image(systemName: "transmission")
        
        //New Load
        if let url = URL(string : "https:\(url_string)") {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    // "Handle" the error
                    fatalError("Error: \(error.localizedDescription)")
                } else if let data = data {
                    
                    // Process the retrieved json
                    let newImage = UIImage(data : data)
                    
                    //store data using the main thread
                    OperationQueue.main.addOperation {
                        print("loading image")
                        
                        self.map[url_string] = Image(uiImage: newImage!)
                    }
                }
            }
            task.resume()
            
        //Error during url creation
        } else {
            fatalError("Error during url creation")
        }
    }
    
}
