//
//  CityDatabaseLoader.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/29/21.
//

import Foundation

class CityDatabaseLoader {
    
    class func copyDatabaseFile() {
        let fileManager = FileManager.default
        do {
            let url = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("database.sqlite")
            if fileManager.fileExists(atPath: url.path) {
                print("Database file already exists at path: \(url.path)")
                return
            }
            guard let bundleURL = Bundle.main.url(forResource: "database", withExtension: "sqlite") else {
                fatalError("Database file didn't find at main bundle")
            }
            try fileManager.copyItem(at: bundleURL, to: url)
        } catch {
            print(error)
        }        
    }
    
}
