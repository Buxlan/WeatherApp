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
    private var managedObjectContext = CoreDataManager.shared.privateObjectContext
    private lazy var completionCitiesHandler: (([City]) -> Void) = { [weak self] cities in
        self?.update(at: cities)
    }
    private lazy var completionWeatherDataHandler: ((City, DailyWeatherList) -> Void) = { [weak self] city, weatherList in
        guard let self = self else {
            return
        }
        self.managedObjectContext.perform {
            let currentWeatherData = CurrentWeatherData(temp: weatherList.current.temp)
            let currentWeather = CurrentWeather(currentWeatherData: currentWeatherData,
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
    
    private var timer: Timer?
    // MARK: - Init
    
    init() {
        
    }
    
    init(updateByTimer: Bool) {
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
        
    // MARK: - Helper methods
    
    func update() {
        // get cities
        cityManager.fetchRequestCitiesForWeatherUpdate(completionHandler: completionCitiesHandler)
    }
        
    func update(at cities: [City]) {
        cities.forEach { (city) in
            let weatherRequest = WeatherHttpRequest(city: city)
            weatherRequest.fetchRequest(completionHandler: completionWeatherDataHandler)
        }
    }
    
}

extension WeatherManager {
    var authKey: String {
        (Bundle.main.object(forInfoDictionaryKey: "weatherAuthKey") as? String) ?? ""
    }
    
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
    
    @objc
    private func timerHandle() {
        print("update by timer")
        update()
    }
}
