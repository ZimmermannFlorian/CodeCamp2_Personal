//
//  ImageCache.swift
//  WeatherApp
//
//  Created by florian on 28.10.25.
//
import SwiftUI
import Combine

/*
    This class uses the integrated url cache,
    to cache the images, that way we are letting
    the OS cache old images, this works because the
    images have the cache-control field in the respone
    to public & set a max age of 31919000 which is roughly a year
*/
class ImageCache : ObservableObject{
    @Published var map: [String: Image] = [:]
    var requester : NetworkRequest
    
    init() {
        
        //Construct network callback
        self.requester = NetworkRequest()
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
            debugPrint("loading image")
            
            let strID = String(url.dropFirst(6))

            //show new image
            self.map[strID] = Image(uiImage: newImage!)
        }
    }
    
}
