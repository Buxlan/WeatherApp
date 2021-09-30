//
//  WeatherByDateViewModel.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/25/21.
//

import Foundation
import CoreData

class DailyWeatherViewModel {
        
    // MARK: - Properties
    var city: City? {
        didSet {
            update()
        }
    }
    
    typealias ItemType = City
    typealias CellModelType = MainDataModel
    
    var dailyWeatherList: DailyWeatherList? {
        didSet {
            delegate?.update()
            completionTaskHandler = nil
        }
    }
    
    var completionTaskHandler: ((DailyWeatherList?) -> Void)?
    var itemsCount: Int {
        return dailyWeatherList?.daily.count ?? 0
    }
    
    weak var delegate: (Updatable)?
    // MARK: - Init    
            
    // MARK: - Helper functions
    func update() {
        guard let city = city else {
            return
        }
        let completionHandler: (DailyWeatherList?) -> Void = { [weak self] list in
            self?.dailyWeatherList = list
        }
        completionTaskHandler = completionHandler
        DailyWeatherManager.shared.updateDailyWeather(at: city, completionHandler: completionHandler)
    }
    
    func item(at indexPath: IndexPath) -> CellModelType {
        if let dailyWeather = dailyWeatherList?.daily[indexPath.row] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/YY"
            let text = dateFormatter.string(from: dailyWeather.dt)
            let detailText = "\(dailyWeather.temp.day)"
            return CellModelType(text: text, detailText: detailText)
        } else {
            return CellModelType(text: "Unknown", detailText: "--??--")
        }
    }
    
}

extension DailyWeatherViewModel: Observer {
    
    func notify() {
        self.update()
    }
    
}
