//
//  MVC_Settings.swift
//  WeatherApp
//
//  Created by florian on 29.10.25.
//

import Foundation
import SwiftUI
import SwiftData

struct MVC_Settings : Codable, Hashable{
    
    //Uses Fahrenheit on True, Celsius as default
    var useFahrenheit : Bool {
        get {
            return UserDefaults.standard.bool(forKey: "useFahrenheit")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "useFahrenheit")
        }
    }
    
    //Uses Miles/H on True, KM/H as default
    var useMiles : Bool {
        get {
            return UserDefaults.standard.bool(forKey: "useMiles")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "useMiles")
        }
    }
}
