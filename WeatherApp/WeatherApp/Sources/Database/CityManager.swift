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
    
    // MARK: - Properties

    private var managedObjectContext: NSManagedObjectContext
    
    // MARK: - Init
    
    init() {
        self.managedObjectContext = CoreDataManager.shared.privateObjectContext
    }
    
    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
    }
    
    // MARK: Helper fuctions
    
    func fetchRequestCitiesForWeatherUpdate(completionHandler: @escaping ([City]) -> Void) {
        managedObjectContext.perform {
            let request = City.prepareCitiesForUpdateRequest()
            do {
                let result = try self.managedObjectContext.fetch(request)
                completionHandler(result)
            } catch {
                // error handling
                print(error)
            }
            return completionHandler([])
        }
    }
    
    func fetchRequestCurrentCity(completionHandler: @escaping (CityData?) -> Void) {
        var cityData: CityData?
        managedObjectContext.perform {
            let request = City.prepareCurrentCityFetchRequest()
            do {
                let result = try self.managedObjectContext.fetch(request)
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
        
    func determineNearestCity(by location: CLLocation,
                              completionHandler: (() -> Void)?) {
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
                    city.isCurrent = true
                    do {
                        try CoreDataManager.shared.save(self.managedObjectContext)
                        DispatchQueue.global(qos: .userInitiated).async {
                            WeatherManager.shared.update(at: city.objectID)
                        }
                    } catch {
                        print(error)
                    }
                    completionHandler?()
                    return
                }
            } catch {
                // error handling
                print(error)
            }
            completionHandler?()
        }
    }
    
}
