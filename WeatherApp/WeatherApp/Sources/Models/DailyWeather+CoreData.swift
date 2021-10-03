//
//  DailyWeather+CoreData.swift
//  
//
//  Created by  Buxlan on 10/3/21.
//
//

import Foundation
import CoreData

@objc(DailyWeather)
public class DailyWeather: NSManagedObject {
    
    private static let entityName = "DailyWeather"
    
    @NSManaged var date: Date
    @NSManaged var temp: Float
    @NSManaged var city: City?
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init(city: City, dailyWeather: DailyWeatherData, insertInto context: NSManagedObjectContext) {
        let manager = CoreDataManager.shared
        self.init(entity: manager.entityForName(entityName: Self.entityName, context: context),
                  insertInto: context)
        self.city = city
        self.date = dailyWeather.date
        self.temp = dailyWeather.temp.day
    }
    
    @nonobjc public class func prepareFetchRequest() -> NSFetchRequest<DailyWeather> {
        return NSFetchRequest<DailyWeather>(entityName: entityName)
    }
}
