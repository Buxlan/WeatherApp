//
//  CityManager.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/21/21.
//

import UIKit
import CoreData
import CoreLocation

class CityManager {
    
    static let shared: CityManager = CityManager()
//    private var observers: [CurrentCityObserver] = [CurrentCityObserver]()
    var nearestCity: City?
//    {
//        didSet {
//            if let nearestCity = self.nearestCity {
//                observers.forEach {
//                    $0.didChange(currentCity: nearestCity)
//                }
//            }
//        }
//    }
    private var managedObjectContext: NSManagedObjectContext?
    
    // MARK: - Init
    
    // MARK: Helper fuctions
    func requestCurrentCity(completionHandler: @escaping (CityData?) -> Void) {
        let context = CoreDataManager.shared.privateObjectContext
        var cityData: CityData?
        managedObjectContext = context
        context.perform {
            let request = City.prepareCurrentCityFetchRequest()
            do {
                let result = try context.fetch(request)
                if let city = result.first {
                    cityData = CityData(city: city)
                    completionHandler(cityData)
                }
            } catch {
                // error handling
                print(error)
            }
        }
    }
    
    func determineNearestCity(by location: CLLocation, completionHandler: @escaping (CityData?) -> Void) {
        let context = CoreDataManager.shared.privateObjectContext
        managedObjectContext = context
        context.perform {  [weak self] in
            guard let self = self else {
                return
            }
            let latitude = Float(location.coordinate.latitude)
            let longitude = Float(location.coordinate.longitude)
            let request = City.prepareNearestCitiesFetchRequest(latitude: latitude,
                                                                longitude: longitude)
            do {
                let cities = try context.fetch(request)
                var distances = [City: CLLocationDistance]()
                cities.forEach { (city) in
                    let cityLocation = CLLocation(latitude: Double(city.coordLatitude),
                                                  longitude: Double(city.coordLongitude))
                    let distance = location.distance(from: cityLocation)
                    distances[city] = distance
                }
                let sortedDistances = distances.sorted {
                    $0.value < $1.value
                }
                if let first = sortedDistances.first {
                    let city = first.key
                    self.nearestCity = city
                    city.isChosen = true
                    city.isCurrent = true
                    do {
                        try CoreDataManager.shared.save(context)
//                        DispatchQueue.global(qos: .userInitiated).async {
//                            CurrentWeatherManager.shared.update()
//                        }
                    } catch {
                        print(error)
                    }
                    self.managedObjectContext = nil
                    completionHandler(CityData(city: city))
                    return
                }
            } catch {
                // error handling
                print(error)
            }
            completionHandler(nil)
            self.managedObjectContext = nil
        }
    }
    
}
