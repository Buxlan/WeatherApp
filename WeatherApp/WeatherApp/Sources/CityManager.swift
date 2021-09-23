//
//  CityManager.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/21/21.
//

import UIKit
import CoreData

struct CityManager {
    
    static func initCitiesFromFile() -> Bool {
        guard let url = Bundle.main.url(forResource: "city.list", withExtension: "json") else {
            print("Cities: cannot find file with needed url")
            return false
        }
        var data = Data()
        do {
            data = try Data(contentsOf: url)
        } catch {
            print("File with cities cannot be loaded, error: \(error.localizedDescription)")
            return false
        }
        
        do {
            let decoder = JSONDecoder()
            let cities = try decoder.decode([City].self, from: data)
            if cities.count == 0 {
                print("File with cities is empty")
                return false
            }
        } catch {
            print("File with cities cannot be decoded, error \(error.localizedDescription)")
            return false
        }
        CoreDataManager.instance.saveContext()
        
        return true
    }
    
}
