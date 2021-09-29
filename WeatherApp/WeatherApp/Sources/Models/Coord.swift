//
//  Coord.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/29/21.
//

struct Coord: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case longitude = "lon"
        case latitude = "lat"
    }
    
    var longitude: Double
    var latitude: Double
    
    init(longitude: Double,
         latitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
