//
//  CityFileLoader.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/29/21.
//

import Foundation

class CityFileLoader {
    static private func loadCitiesFromFile() {
        guard let url = Bundle.main.url(forResource: "city.list", withExtension: "json") else {
            print("Cities: cannot find file with needed url")
            return
        }
                
        do {
            var data = Data()
            data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let context = CoreDataManager.shared.privateObjectContext
            context.perform {
                do {
                    let citiesData = try decoder.decode([CityData].self, from: data)
                    if citiesData.count == 0 {
                        print("File with cities is empty")
                        return
                    }
                    _ = citiesData.map { (cityData) -> City in
                        City(cityData: cityData, context: context)
                    }
                    if context.hasChanges {
                        try context.save()
                        AppController.shared.areCitiesLoaded = true
                    }
    //                    self.notifyObservers()
                } catch {
                    print(error)
                }
            }
            
        } catch {
            print("File with cities cannot be decoded, error \(error)")
            return
        }
    }
}
