//
//  AppController.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/22/21.
//

import Foundation

class AppController {
    
    static let shared = AppController()
    
    var isFirstLaunch: Bool {
        get {
            UserDefaults.standard.value(forKey: "isFirstLaunch") == nil
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "isFirstLaunch")
        }
    }
    
    var areCitiesLoaded: Bool {
        get {
            UserDefaults.standard.value(forKey: "areCitiesLoaded") != nil
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "areCitiesLoaded")
        }
    }
}
