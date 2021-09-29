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
//    private var observers: [Observer] = [Observer]()
    var nearestCity: City? {
        didSet {
            
        }
    }
    
    private let managedObjectContext = CoreDataManager.shared.privateObjectContext
    
    // MARK: - Init
    
    // MARK: Helper fuctions
    
    func determineCity(by location: CLLocation) {
        managedObjectContext.perform {  [weak self] in
            guard let self = self else {
                return
            }
            let request = City.prepareNearestCitiesFetchRequest(latitude: Float(location.coordinate.latitude),
                                                                longitude: Float(location.coordinate.longitude))
            do {
                let cities = try self.managedObjectContext.fetch(request)
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
                    self.nearestCity = first.key
                }
            } catch {
                print(error)
            }
        }
    }

    static func prepareCitiesIfNeeded() {
        if AppController.shared.areCitiesLoaded {
            return
        }
        CityDatabaseLoader.copyDatabaseFile()
    }
    
}
