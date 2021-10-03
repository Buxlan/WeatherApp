//
//  NetworkDataModels.swift
//  WeatherApp
//
//  Created by  Buxlan on 10/3/21.
//

import Foundation

struct TempData: Decodable {
    var day: Float
    var temp: Float
    var max: Float
    var night: Float
    var eve: Float
    var morn: Float
}

struct CurrentTempData: Decodable {
    var dt: TimeInterval
    var temp: Float
    
    var date: Date {
        let timeInterval = TimeInterval(dt)
        let date = Date(timeIntervalSince1970: timeInterval)
        return date
    }
}

struct DailyWeatherData: Decodable {
    
    enum CodingKeys: CodingKey {
        case dt
        case temp
    }
    var dt: TimeInterval
    var date: Date
    var temp: TempData
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dt = try container.decode(TimeInterval.self, forKey: .dt)
        let timeInterval = TimeInterval(dt)
        self.dt = dt
        self.date = Date(timeIntervalSince1970: timeInterval)
        self.temp = try container.decode(TempData.self, forKey: .temp)
    }
    
    init() {
        self.date = Date()
        self.dt = TimeInterval()
        self.temp = TempData(day: 0, temp: 0, max: 0, night: 0, eve: 0, morn: 0)
    }
    
    init(data: DailyWeather) {
        self.date = data.date
        self.dt = data.date.timeIntervalSince1970
        self.temp = TempData(day: data.temp, temp: 0.0, max: 0.0, night: 0.0, eve: 0.0, morn: 0.0)
    }
    
}

struct DailyWeatherList: Decodable {
    var current: CurrentTempData
    var daily: [DailyWeatherData]
}
