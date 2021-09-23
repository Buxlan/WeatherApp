//
//  ChoosedCity.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/24/21.
//

import CoreData
import CoreLocation

@objc(City)
class ChoosedCity: NSManagedObject {
    
    enum CodingKeys: CodingKey {
        case name
        case id
        case country
        case state
        case coord
    }
    
    @NSManaged var city: City
    @NSManaged var weather: CurrentWeather
        
    convenience init() {
        let manager = CoreDataManager.instance
        self.init(entity: manager.entityForName(entityName: "ChoosedCity"),
                  insertInto: manager.privateObjectContext)
    }
    
}

extension ChoosedCity {
    var coord: CLLocationCoordinate2D {
        return self.city.coord
    }    
}
