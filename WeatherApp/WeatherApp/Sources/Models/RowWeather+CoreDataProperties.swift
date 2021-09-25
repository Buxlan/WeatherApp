//
//  RowWeather+CoreDataProperties.swift
//  
//
//  Created by  Buxlan on 9/24/21.
//
//

import Foundation
import CoreData

extension WeatherByDate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeatherByDate> {
        return NSFetchRequest<WeatherByDate>(entityName: "WeatherByDate")
    }

    @NSManaged var temp: Float
    @NSManaged var date: Date
    @NSManaged var chosedCity: ChoosedCity?

}
