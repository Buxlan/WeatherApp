//
//  Temperature.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/22/21.
//

import Foundation
import CoreData

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

@objc(CurrentWeather)
class CurrentWeather: NSManagedObject {
    
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
    
    @NSManaged var city: City?
    @NSManaged var temp: Float
    
    convenience init(insertInto context: NSManagedObjectContext?) {
        let manager = CoreDataManager.shared
        self.init(entity: manager.entityForName(entityName: "CurrentWeather", context: context),
                  insertInto: context)
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init(currentWeatherData: CurrentWeatherData, context: NSManagedObjectContext) {
        let manager = CoreDataManager.shared
        self.init(entity: manager.entityForName(entityName: "CurrentWeather", context: context),
                  insertInto: context)
        self.temp = currentWeatherData.temp
    }
    
    // MARK: Helper methods
    @nonobjc public class func prepareFetchRequest() -> NSFetchRequest<CurrentWeather> {
        let request = NSFetchRequest<CurrentWeather>(entityName: "CurrentWeather")
        request.sortDescriptors = [NSSortDescriptor(key: "city.name", ascending: true)]
        return request
    }
}
