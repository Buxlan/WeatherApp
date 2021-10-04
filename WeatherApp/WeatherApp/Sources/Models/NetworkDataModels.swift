//
//  NetworkDataModels.swift
//  WeatherApp
//
//  Created by  Buxlan on 10/3/21.
//

import Foundation

struct TempData: Decodable {
    var day: Float
    var min: Float
    var max: Float
    var night: Float
    var eve: Float
    var morn: Float
}

struct CurrentTempData: Decodable {
    var dt: TimeInterval
    var temp: Float
}

extension CurrentTempData {
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
        let dt = try container.decode(Int.self, forKey: .dt)
        let timeInterval = TimeInterval(dt)
        self.dt = timeInterval
        self.date = Date(timeIntervalSince1970: timeInterval)
        self.temp = try container.decode(TempData.self, forKey: .temp)
    }
    
    init() {
        self.date = Date()
        self.dt = TimeInterval()
        self.temp = TempData(day: 0, min: 0, max: 0, night: 0, eve: 0, morn: 0)
    }
    
    init(data: DailyWeather) {
        self.date = data.date
        self.dt = data.date.timeIntervalSince1970
        self.temp = TempData(day: data.temp, min: 0.0, max: 0.0, night: 0.0, eve: 0.0, morn: 0.0)
    }
    
}

struct DailyWeatherList: Decodable {
    
    enum CodingKeys: CodingKey {
        case current
        case daily
    }
    
    var current: CurrentTempData
    var daily: [DailyWeatherData]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let current = try container.decode(CurrentTempData.self, forKey: .current)
        let daily = try container.decode([DailyWeatherData].self, forKey: .daily)
        self.current = current
        self.daily = daily
    }
}

struct CurrentWeatherList: Decodable {
    
    enum CodingKeys: CodingKey {
        case main
    }
    
    var data: CurrentWeatherData
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var temp = CurrentWeatherData(temp: 0.0)
        do {
            temp = try container.decode(CurrentWeatherData.self, forKey: .main)
        } catch {
            print("Warning: cannot decode weather data for city: \(error)")
        }
        data = temp
    }
}

struct CurrentWeatherData: Decodable {
    var temp: Float
}
