//
//  CityManager.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/21/21.
//

import UIKit
import CoreData

struct CityManager {
    
    static func initCitiesFromFile() {
        guard let url = Bundle.main.url(forResource: "city.list", withExtension: "json") else {
            print("Cities: cannot find file with needed url")
            return
        }
        var data = Data()
        do {
            data = try Data(contentsOf: url)
        } catch {
            print("File with cities cannot be loaded, error: \(error.localizedDescription)")
            return
        }
                
        do {
            let decoder = JSONDecoder()
            let cities = try decoder.decode([City].self, from: data)
            if cities.count == 0 {
                print("File with cities is empty")
                return
            }
        } catch {
            print("File with cities cannot be decoded, error \(error.localizedDescription)")
            return
        }
        
        let context = CoreDataManager.instance.privateObjectContext
        CoreDataManager.instance.save(context)
        AppController.shared.areCitiesLoaded = true
    }
}
