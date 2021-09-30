//
//  CityFileLoader.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/29/21.
//

import Foundation

class CityFileLoader {
    func perform() {
        guard let url = Bundle.main.url(forResource: "city.list", withExtension: "json") else {
            print("Cities: cannot find file with needed url")
            return
        }
        do {
            var data = Data()
            data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            do {
                let citiesData = try decoder.decode([CityData].self, from: data)
                if citiesData.count == 0 {
                    fatalError("File with cities is empty")
                }
            } catch {
                print(error)
            }
        } catch {
            fatalError("File with cities cannot be decoded, error \(error)")
        }
    }
}
