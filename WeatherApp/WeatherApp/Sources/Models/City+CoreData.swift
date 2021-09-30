//
//  City.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/21/21.
//

import CoreData
import CoreLocation

@objc(City)
class City: NSManagedObject {    
    
    @NSManaged public var coordLatitude: Float
    @NSManaged public var coordLongitude: Float
    @NSManaged public var country: String?
    @NSManaged public var id: Int32
    @NSManaged public var isChosen: Bool
    @NSManaged public var isCurrent: Bool
    @NSManaged public var name: String
    @NSManaged public var state: String?
    @NSManaged public var currentWeather: CurrentWeather?
    
    convenience init(cityData: CityData, context: NSManagedObjectContext) {
        let manager = CoreDataManager.shared
        self.init(entity: manager.entityForName(entityName: "City", context: context),
                  insertInto: context)
        self.id = cityData.id
        self.name = cityData.name
        self.country = cityData.country
        self.state = cityData.state
        self.currentWeather = nil
        self.isChosen = false
        self.isCurrent = false
        let latitude = Float(cityData.coord?.latitude ?? 0.0)
        let longitude = Float(cityData.coord?.longitude ?? 0.0)
        self.coordLatitude = latitude
        self.coordLongitude = longitude
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}

extension City {
    
    var coord: Coord {
        Coord(longitude: Double(self.coordLongitude), latitude: Double(self.coordLatitude))
    }
    
    @nonobjc public class func prepareFetchRequest() -> NSFetchRequest<City> {
        let request = NSFetchRequest<City>(entityName: "City")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return request
    }
    
    @nonobjc public class func prepareNearestCitiesFetchRequest(latitude: Float,
                                                                longitude: Float) -> NSFetchRequest<City> {
        let request = NSFetchRequest<City>(entityName: "City")
        request.sortDescriptors = []
        let latitudeMax: Float = latitude + 1.0,
            latitudeMin: Float = latitude - 1.0,
            longitudeMax: Float = longitude + 1.0,
            longitudeMin: Float = longitude - 1.0,
            predicate = NSPredicate(format: "coordLatitude >= %f and coordLatitude <= %f and coordLongitude >= %f and coordLongitude <= %f",
                                    latitudeMin,
                                    latitudeMax,
                                    longitudeMin,
                                    longitudeMax)
        request.predicate = predicate
        return request
    }
    
    func addEntities(data: [CityData]) {
        let context = CoreDataManager.shared.privateObjectContext
        context.perform {
            do {
                _ = data.map { (cityData) -> City in
                    City(cityData: cityData, context: context)
                }
                if context.hasChanges {
                    try context.save()
                    AppController.shared.areCitiesLoaded = true
                }
            } catch {
                print(error)
            }
        }
        
    }
}
