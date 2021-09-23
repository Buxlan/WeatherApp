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
    
    @NSManaged var id: Int32
    @NSManaged var name: String
    @NSManaged var state: String?
    @NSManaged var country: String?
    @NSManaged var selected: Bool
    @NSManaged private var coordLat: Float
    @NSManaged private var coordLon: Float
    
//    var id: Int32? {
//        let value = self.value(forKey: CodingKeys.id.stringValue)
//        return value as? Int32
//    }
//    var name: String? {
//        let value = self.value(forKey: CodingKeys.name.stringValue)
//        return value as? String
//    }
//    var state: String? {
//        let value = self.value(forKey: CodingKeys.state.stringValue)
//        return value as? String
//    }
//    var country: String? {
//        let value = self.value(forKey: CodingKeys.country.stringValue)
//        return value as? String
//    }
//
//    var isSelected: Bool {
//        let value = self.value(forKey: "selected")
//        return value as? Bool ?? false
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
        state = try container.decode(String.self, forKey: .state)
        country = try container.decode(String.self, forKey: .country)
        let coord = try container.decode(Coord.self, forKey: .coord)
        coordLat = 0
        coordLon = 0
        selected = false
//        self.setValue(try container.decode(Int32.self, forKey: .id), forKey: CodingKeys.id.stringValue)
//        self.setValue(try container.decode(String.self, forKey: .name), forKey: CodingKeys.name.stringValue)
//        self.setValue(try container.decode(String.self, forKey: .state), forKey: CodingKeys.state.stringValue)
//        self.setValue(try container.decode(String.self, forKey: .country), forKey: CodingKeys.country.stringValue)
//        let coord = try container.decode(Coord.self, forKey: .coord)
//        self.setValue(coord.lat, forKey: "coordLat")
//        self.setValue(coord.lon, forKey: "coordLon")
//        self.setValue(false, forKey: "selected")
    }
}

extension City {
    var coord: CLLocationCoordinate2D {
        var coord: CLLocationCoordinate2D = .init()
        coord.latitude = CLLocationDegrees(self.coordLat ?? 0)
        coord.longitude = CLLocationDegrees(self.coordLon ?? 0)
        return coord
    }
    
    func setSelected(value: Bool) {
        self.setValue(value, forKey: "selected")
    }
    
}
