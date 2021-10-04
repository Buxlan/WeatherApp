//
//  Temperature.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/22/21.
//

import Foundation
import CoreData

@objc(CurrentWeather)
class CurrentWeather: NSManagedObject {
        
    @NSManaged var city: City
    @NSManaged var temp: Float
    
    convenience init(insertInto context: NSManagedObjectContext?) {
        let manager = CoreDataManager.shared
        self.init(entity: manager.entityForName(entityName: "CurrentWeather", context: context),
                  insertInto: context)
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init(city: City,
                     currentWeatherData: CurrentWeatherData,
                     context: NSManagedObjectContext) {
        let manager = CoreDataManager.shared
        self.init(entity: manager.entityForName(entityName: "CurrentWeather", context: context),
                  insertInto: context)
        self.temp = currentWeatherData.temp
        self.city = city
    }
    
    // MARK: Helper methods
    @nonobjc public class func prepareFetchRequest() -> NSFetchRequest<CurrentWeather> {
        let request = NSFetchRequest<CurrentWeather>(entityName: "CurrentWeather")
        request.sortDescriptors = [NSSortDescriptor(key: "city.name", ascending: true)]
        return request
    }
}
