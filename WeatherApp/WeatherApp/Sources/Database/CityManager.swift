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
    private let managedObjectContext = CoreDataManager.shared.privateObjectContext
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
    
    // MARK: - Init
    
    // MARK: Helper fuctions
    
    func determineNearestCity(by location: CLLocation, completionHandler: @escaping (CityData?) -> Void) {
        managedObjectContext.perform {  [weak self] in
            guard let self = self else {
                return
            }
            let latitude = Float(location.coordinate.latitude)
            let longitude = Float(location.coordinate.longitude)
            let request = City.prepareNearestCitiesFetchRequest(latitude: latitude,
                                                                longitude: longitude)
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
                    let city = first.key
                    self.nearestCity = city
                    completionHandler(CityData(city: city))
                    return
                }
            } catch {
                // error handling
                print(error)
            }
            completionHandler(nil)
        }
    }
    
}
