//
//  NetworkJsonRequest.swift
//  WeatherApp
//
//  Created by florian on 09.11.25.
//
import Foundation

class NetworkRequest {
    typealias DataCallbackType = (_ data : Data, _ url : String)  -> Void;
    var callback : DataCallbackType?;
    
    init() {
        
    }
    
    func request(_ url_string : String) {
        
        if let url = URL(string : url_string) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                
                if let error = error as? URLError{
                    
                    //Error Handling
                    switch error.code{
                    case .timedOut:
                        fallthrough
                    case .cannotFindHost:
                        fallthrough
                    case .cannotConnectToHost:
                        fallthrough
                    case .notConnectedToInternet:
                        debugPrint("No Internet connection");
                    default:
                        debugPrint("Error: \(error.localizedDescription)")
                    }
                    
                } else if let data = data {
                    self.callback!(data, url_string)
                }
            }
            task.resume()
            
        //Error during url creation
        } else {
            debugPrint("Error during url creation")
        }
        
    }
    
}
