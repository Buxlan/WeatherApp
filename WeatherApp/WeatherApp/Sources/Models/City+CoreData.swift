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
    @NSManaged public var name: String
    @NSManaged public var state: String?
    @NSManaged public var currentWeather: CurrentWeather?
    
    convenience init(cityData: CityData, context: NSManagedObjectContext) {
        let manager = CoreDataManager.shared
        self.init(entity: manager.entityForName(entityName: "City"),
                  insertInto: context)
        self.id = cityData.id
        self.name = cityData.name
        self.country = cityData.country
        self.state = cityData.state
        self.currentWeather = nil
        self.isChosen = false
        let latitude = Float(cityData.coord?.latitude ?? 0.0)
        let longitude = Float(cityData.coord?.latitude ?? 0.0)
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
        let fetchRequest = City.prepareFetchRequest()
        let latitudeMax: Float = Float(latitude + 1.0),
            latitudeMin: Float = Float(latitude - 1.0),
            longitudeMax: Float = Float(longitude + 1.0),
            longitudeMin: Float = Float(longitude - 1.0),
            predicate = NSPredicate(format: "coordLatitude > %f and coordLatitude < %f and coordLongitude > %f and coordLongitude < %f",
                                    latitudeMin,
                                    latitudeMax,
                                    longitudeMin,
                                    longitudeMax)
        fetchRequest.predicate = predicate
        return fetchRequest
    }
}
