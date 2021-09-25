//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/22/21.
//

import Network
import UIKit
import CoreData

class WeatherManager: NSObject {
    
    static let shared = WeatherManager()
    private var observers: [Observer] = [Observer]()
        
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        return session
    }()
    
    func updateWeather() {
        let fetchRequest = ChoosedCity.prepareFetchRequest()
        let context = CoreDataManager.instance.privateObjectContext
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        context.perform {
            do {
                try fetchedResultsController.performFetch()
                if let objects = fetchedResultsController.fetchedObjects {
                    objects.forEach { choosedCity in
                        self.updateWeather(at: choosedCity.objectID, in: context)
                    }
                }
            } catch {
                print(error)
            }
        }
        CoreDataManager.instance.save(context)
        self.observers.forEach {
            $0.notify()
        }
    }
    
    func updateWeather(at objectID: NSManagedObjectID, in context: NSManagedObjectContext) {
        guard let choosedCity = context.object(with: objectID) as? ChoosedCity else {
            print("Error: cant get object Choosed city")
            return
        }
        updateCurrentWeather(at: choosedCity, in: context, completion: nil)
        updateWeatherByDays(at: choosedCity, in: context)
        
    }
    
    func updateCurrentWeather(at city: ChoosedCity,
                              in context: NSManagedObjectContext,
                              completion: (() -> Void)? = nil) {
        let id = city.city.id
        let urlString = "https://api.openweathermap.org/data/2.5/weather?id=\(id)&appid=7097b7d0449c11e0933f4a5d2dfd47da&units=metric"
        print(urlString)
        guard let url = URL(string: urlString) else {
            return
        }
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    // current weather is always created at private context!
                    let currentWeather = try decoder.decode(CurrentWeather.self, from: data)
                    switch context {
                    case CoreDataManager.instance.privateObjectContext:
                        currentWeather.choosedCity = city
                    default:
                        let newContext = CoreDataManager.instance.privateObjectContext
                        if let cityNew = try newContext.existingObject(with: city.objectID) as? ChoosedCity {
                            currentWeather.choosedCity = cityNew
                            completion?()
                        }
                    }
                    CoreDataManager.instance.save(context)
                    
                } catch let DecodingError.dataCorrupted(context) {
                    print(context)
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.typeMismatch(type, context) {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch {
                    print("error: ", error)
                }
            }
        }
        task.resume()
    }
    
    func updateWeatherByDays(at city: ChoosedCity, in context: NSManagedObjectContext) {
        
    }
    
    func addObserver(_ observer: Observer) {
        observers.append(observer)
    }
    
    func removeObserver(_ observer: Observer) {
        if let index = observers.firstIndex(where: { $0 === observer }) {
            observers.remove(at: index)
        }
    }
    
    func removeAllObservers() {
        observers.removeAll()
    }
    
    deinit {
        removeAllObservers()
    }
    
}
