//
//  CurrentWeatherManager.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/27/21.
//

import Network
import UIKit
import CoreData

class CurrentWeatherManager: NSObject {
    
    var isNeededToUpdate: Bool = false
    
    static let shared = CurrentWeatherManager()
    private lazy var session: URLSession = {
        URLSession.shared
    }()
    private var timer: Timer?
    
    // MARK: - Init
    
    private override init() {
        super.init()
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Helper methods
    
    func startTimer() {
        guard timer == nil else { return }
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 300.0,
                                              target: self,
                                              selector: #selector(self.timerHandle),
                                              userInfo: nil,
                                              repeats: true)
        }
    }

    func stopTimer() {
        guard timer != nil else { return }
        DispatchQueue.main.async {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    private func prepareRequest(city: City) -> URLRequest? {
        let authKey = NetworkManager.authKey
        let id = city.id
        let urlString = "https://api.openweathermap.org/data/2.5/weather?id=\(id)&appid=\(authKey)&units=metric"
        guard let url = URL(string: urlString) else {
            print("Invalid url")
            return nil
        }
        let request = URLRequest(url: url)
        return request
    }
    
    private var completionHandler: ((CurrentWeatherList) -> Void)?
    
    func update() {
        let context = CoreDataManager.shared.privateObjectContext
        context.perform {            
            do {
                let fetchRequest = City.prepareFetchRequest()
                fetchRequest.predicate = NSPredicate(format: "%K == %@ OR %K == %@",
                                                     "isChosen",
                                                     NSNumber(true),
                                                     "isCurrent",
                                                     NSNumber(true))
                let objects = try context.fetch(fetchRequest)
                objects.forEach { city in
                    let handler: (CurrentWeatherList) -> Void = { currentWeatherData in
                        let currentWeather = CurrentWeather(currentWeatherData: currentWeatherData.data,
                                                            context: context)
                        currentWeather.city = city
                        do {
                            try CoreDataManager.shared.save(context)
                        } catch {
                            print(error)
                        }
                    }
                    self.completionHandler = handler
                    self.fetchRequestCurrentWeather(at: city,
                                                    completionHandler: handler)
                }
            } catch {
                print(error)
            }
        }
        
    }
    
    func update(at cityObjectID: NSManagedObjectID) {
        let context = CoreDataManager.shared.privateObjectContext
        context.perform {
            let object = context.object(with: cityObjectID)
            guard let city = object as? City else {
                return
            }
            let handler: (CurrentWeatherList) -> Void = { currentWeatherData in
                let currentWeather = CurrentWeather(currentWeatherData: currentWeatherData.data,
                                                    context: context)
                currentWeather.city = city
                do {
                    try CoreDataManager.shared.save(context)
                } catch {
                    print(error)
                }
            }
            self.completionHandler = handler
            self.fetchRequestCurrentWeather(at: city,
                                            completionHandler: handler)
        }
        
    }
    
    private func fetchRequestCurrentWeather(at city: City,
                                      completionHandler: @escaping ((CurrentWeatherList) -> Void)) {
        guard let request = prepareRequest(city: city) else {
            return
        }
        let handler: ((Data?, URLResponse?, Error?) -> Void) = { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let data = data else {
                print("Data is nil")
                return
            }
            let decoder = JSONDecoder()
            do {
                let currentWeatherData = try decoder.decode(CurrentWeatherList.self, from: data)
                completionHandler(currentWeatherData)
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
        let task = session.dataTask(with: request,
                                    completionHandler: handler)
        task.resume()
    }
    
    @objc
    private func timerHandle() {
        print("update by timer")
        update()
    }
    
}
