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
    var requester : NetworkRequest
    
    init() {
     
        //Construct network callback
        self.requester = NetworkRequest();
        self.requester.callback = self.dataCallback
        
    }
    
    func loadImage(_ url_string : String) {
        
        //Already loaded?
        if map.contains(where: { (key, value) in key == url_string }) {
            return
        }
        
        //Load Placeholder
        map[url_string] = Image(systemName: "transmission")
        
        //start requesting the new image
        requester.request("https:\(url_string)")
    }
    
    //gets called on different threads then MAIN!
    func dataCallback(data : Data, url : String) {
        
        // Process the retrieved Image
        let newImage = UIImage(data : data)
        
        //store data using the main thread
        OperationQueue.main.addOperation {
            print("loading image")
            let strID = String(url.dropFirst(6))
            self.map[strID] = Image(uiImage: newImage!)
        }
    }
    
}
