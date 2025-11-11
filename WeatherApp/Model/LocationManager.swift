//
//  LocationManager.swift
//  WeatherApp
//
//  Created by florian on 02.11.25.
//

import SwiftUI
import Combine
import CoreLocation

class LocationManager : NSObject, CLLocationManagerDelegate, ObservableObject{
    @Published var locationStr : String
    var locationManager = CLLocationManager()
    
    public override init() {
        self.locationStr = "Kassel"
        super.init()
        
        //Setup Manager
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = DistanceSQForPosUpdate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        debugPrint("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currLocation = locations.first!
        locationStr = "\(currLocation.coordinate.latitude), \(currLocation.coordinate.longitude)";
        debugPrint("Location Update Received \(locationStr)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        debugPrint("New Authorization Status: \(status.rawValue)")
    }
    
    func startListener() {
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }
    
}
