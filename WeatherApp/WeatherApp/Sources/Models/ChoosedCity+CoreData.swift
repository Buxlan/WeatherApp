//
//  ChoosedCity.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/24/21.
//

import CoreData
import CoreLocation

@objc(ChoosedCity)
class ChoosedCity: NSManagedObject {
    
    enum CodingKeys: CodingKey {
        case name
        case id
        case country
        case state
        case coord
    }
    
    @NSManaged var city: City
    @NSManaged var currentWeather: CurrentWeather?
        
    convenience init(insertInto: NSManagedObjectContext) {
        let manager = CoreDataManager.instance
        self.init(entity: manager.entityForName(entityName: "ChoosedCity"),
                  insertInto: insertInto)
    }
    
    // MARK: - Helper functions
    @nonobjc public class func prepareFetchRequest() -> NSFetchRequest<ChoosedCity> {
        let request = NSFetchRequest<ChoosedCity>(entityName: "ChoosedCity")
        request.sortDescriptors = []
        return request
    }
    
}

extension ChoosedCity {
    var name: String {
        return self.city.name
    }
    var coord: CLLocationCoordinate2D {
        return self.city.coord
    }
}
