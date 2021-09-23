//
//  Temperature.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/22/21.
//

import Foundation

struct WeatherData: Decodable {
    
    var id: Int
    
    
}

struct CurrentWeatherData: Decodable {
    
    enum CodingKeys: CodingKey {
        case main
    }
    
    enum MainSectionCodingKeys: String, CodingKey {
        case temp
        case pressure
        case humidity
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
    
    var temp: Float
    
    init(from decoder: Decoder) throws {
        let data = try decoder.container(keyedBy: CodingKeys.self)
        let main = try data.nestedContainer(keyedBy: MainSectionCodingKeys.self, forKey: .main)
        self.temp = try main.decode(Float.self, forKey: .temp)
        print(temp)
    }
}
