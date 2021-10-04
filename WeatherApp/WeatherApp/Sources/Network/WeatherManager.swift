//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/22/21.
//

import Network
import UIKit
import CoreData

class WeatherManager {
    
    static let shared = WeatherManager()
    
    private lazy var cityManager: CityManager = {
        CityManager(context: managedObjectContext)
    }()
    private var httpRequests = [WeatherHttpRequest]()
    private var managedObjectContext = CoreDataManager.shared.privateObjectContext
    private lazy var completionUpdatingCitiesHandler: (([NSManagedObjectID]) -> Void) = { (cities) in
        self.update(at: cities)
    }
    private lazy var completionWeatherDataHandler: ((City, DailyWeatherList) -> Void) = { city, weatherList in
        self.managedObjectContext.perform {
            let currentWeatherData = CurrentWeatherData(temp: weatherList.current.temp)
            let currentWeather = CurrentWeather(city: city,
                                                currentWeatherData: currentWeatherData,
                                                context: self.managedObjectContext)
            let dailyWeather = weatherList.daily.map { (data) -> DailyWeather in
                DailyWeather(city: city, dailyWeather: data, insertInto: self.managedObjectContext)
            }
            do {
                try CoreDataManager.shared.save(self.managedObjectContext)                
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - Init
    
    // MARK: - Helper methods
    
    func update() {
        // get cities
        cityManager.fetchRequesUpdatingCities(completionHandler: completionUpdatingCitiesHandler)
    }
        
    func update(at objectIds: [NSManagedObjectID]) {
        var cities: [City] = []
        managedObjectContext.performAndWait {
            objectIds.forEach { (objectId) in
                if let city = managedObjectContext.object(with: objectId) as? City {
                    cities.append(city)
                }
            }
        }
        update(at: cities)
    }
    
    private func update(at cities: [City]) {
        httpRequests.removeAll()
        cities.forEach { (city) in
            let weatherRequest = WeatherHttpRequest(city: city)
            httpRequests.append(weatherRequest)
            weatherRequest.fetchRequest(completionHandler: completionWeatherDataHandler)
        }
    }
    
}
