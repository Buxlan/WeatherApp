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
    private var observers: [Observer] = [Observer]()
    private lazy var session: URLSession = {
        URLSession.shared
    }()
    private var timer: Timer?
    
    // MARK: - Init
    
    override init() {
        super.init()
        startTimer()
    }
    
    deinit {
        removeAllObservers()
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Helper functions
    
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
                fetchRequest.predicate = NSPredicate(format: "%K == %@", "isChosen", NSNumber(true))
                let objects = try context.fetch(fetchRequest)
                objects.forEach { city in
                    let handler: (CurrentWeatherList) -> Void = { currentWeatherData in
                        let currentWeather = CurrentWeather(currentWeatherData: currentWeatherData.data,
                                                            context: context)
                        currentWeather.city = city
                        if context.hasChanges {
                            do {
                                try context.save()
                                self.completionHandler = nil
                            } catch {
                                print(error)
                            }
                        }
                    }
                    self.completionHandler = handler
                    self.updateCurrentWeather(at: city,
                                              completionHandler: handler)
                }
                if context.hasChanges {
                    try context.save()
                }
                self.observers.forEach {
                    $0.notify()
                }
            } catch {
                print(error)
            }
        }
        
    }
    
    private func updateCurrentWeather(at city: City,
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
            print(String(data: data, encoding: .utf8))
            print(response)
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
    
    func addObserver(_ observer: Observer) {
        observers.append(observer)
    }
    
    func removeObserver(_ observer: Observer) {
        if let index = observers.firstIndex(where: { $0 === observer }) {
            observers.remove(at: index)
        }
    }
    
    private func removeAllObservers() {
        observers.removeAll()
    }
    
    @objc
    private func timerHandle() {
        print("update by timer")
        update()
    }
    
}