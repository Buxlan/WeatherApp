//
//  MainDataModel.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/28/21.
//

import Foundation

protocol DataModel {
    var text: String { get }
    var detailText: String? { get }
}

struct MainDataModel: DataModel {
    var text: String
    var detailText: String?
    
    init(text: String, detailText: String?) {
        self.text = text
        self.detailText = detailText
    }
}

struct DailyWeatherDataModel: DataModel {
    var text: String
    var detailText: String?
    
    init() {
        text = ""
        detailText = nil
    }
    
    init(data: DailyWeatherData) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YY"
        self.text = dateFormatter.string(from: data.date)
        self.detailText = "\(data.temp)"
    }
}
