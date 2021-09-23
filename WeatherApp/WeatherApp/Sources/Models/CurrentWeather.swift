//
//  Temperature.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/22/21.
//

import Foundation
import CoreData

class CurrentWeather: NSManagedObject, Decodable {
    
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
    
    @NSManaged var temp: Float
    
    convenience init() {
        let manager = CoreDataManager.instance
        self.init(entity: manager.entityForName(entityName: "CurrentWeather"),
                  insertInto: manager.privateObjectContext)
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    required convenience init(from decoder: Decoder) throws {
        let manager = CoreDataManager.instance
        self.init(entity: manager.entityForName(entityName: "CurrentWeather"),
                  insertInto: manager.privateObjectContext)
        
        let data = try decoder.container(keyedBy: CodingKeys.self)
        let main = try data.nestedContainer(keyedBy: MainSectionCodingKeys.self, forKey: .main)
        self.temp = try main.decode(Float.self, forKey: .temp)
        print(temp)
    }
}
