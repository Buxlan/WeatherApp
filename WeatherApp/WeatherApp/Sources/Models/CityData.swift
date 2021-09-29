//
//  CityData.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/28/21.
//

import Foundation

struct CityData: Decodable {
    
    enum CodingKeys: CodingKey {
        case name
        case id
        case country
        case state
        case coord
    }
    
    var name: String
    var id: Int32
    var country: String?
    var state: String?
    var coord: Coord?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int32.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.state = try container.decode(String?.self, forKey: .state)
        self.country = try container.decode(String?.self, forKey: .country)
        let coord = try container.decode(Coord?.self, forKey: .coord)
        self.coord = coord        
    }
}
