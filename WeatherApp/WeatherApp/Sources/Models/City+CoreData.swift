//
//  City.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/21/21.
//

import CoreData
import CoreLocation

struct Coord: Decodable {
    var lon: Float
    var lat: Float
}

@objc(City)
class City: NSManagedObject, Decodable {
    
    enum CodingKeys: CodingKey {
        case name
        case id
        case country
        case state
        case coord
    }
    
    @NSManaged public var coordLat: Float
    @NSManaged public var coordLon: Float
    @NSManaged public var country: String?
    @NSManaged public var id: Int32
    @NSManaged public var name: String
    @NSManaged public var state: String?
    @NSManaged public var selected: ChoosedCity?
    @NSManaged public var currentWeather: CurrentWeather?
    
    @nonobjc public class func prepareFetchRequest() -> NSFetchRequest<City> {
        let request = NSFetchRequest<City>(entityName: "City")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return request
    }
    
//    @nonobjc public class func fetchRequest(filter name: String) -> NSFetchRequest<City> {
//        let request = NSFetchRequest<City>(entityName: "City")
//        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
//        let predicate = NSPredicate(format: "%K contains[cd] %@", "name", name)
//        request.predicate = predicate
//        return request
//    }
        
    convenience init() {
        let manager = CoreDataManager.instance
        self.init(entity: manager.entityForName(entityName: "City"),
                  insertInto: manager.privateObjectContext)
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    required convenience init(from decoder: Decoder) throws {
        let manager = CoreDataManager.instance
        self.init(entity: manager.entityForName(entityName: "City"),
                  insertInto: manager.privateObjectContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int32.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        state = try container.decode(String?.self, forKey: .state)
        country = try container.decode(String?.self, forKey: .country)
        let coord = try container.decode(Coord?.self, forKey: .coord)
        coordLat = coord?.lat ?? 0
        coordLon = coord?.lon ?? 0
    }
}

extension City {
    var coord: CLLocationCoordinate2D {
        var coord: CLLocationCoordinate2D = .init()
        coord.latitude = CLLocationDegrees(self.coordLat)
        coord.longitude = CLLocationDegrees(self.coordLon)
        return coord
    }
    
    var isSelected: Bool {
        selected != nil
    }
    
}
