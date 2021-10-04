//
//  DailyWeatherResultsController.swift
//  WeatherApp
//
//  Created by  Buxlan on 10/3/21.
//

import UIKit
import CoreData

class DailyWeatherResultsController: NSFetchedResultsController<DailyWeather> {
    
    // MARK: - Properties
    typealias ItemType = DailyWeather
    var predicateItem: City? {
        didSet {
            configurePredicate()
        }
    }
    
    private let request: NSFetchRequest<ItemType> = {
        let request = ItemType.prepareFetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 5
        return request
    }()
    
    private func configurePredicate() {
        var predicate: NSPredicate?
        if let item = predicateItem {
            let currentDate = Date()
            var dateComponents = DateComponents()
            dateComponents.day = 5
            let calendar = Calendar.current
            if let date = calendar.date(byAdding: dateComponents, to: currentDate) as NSDate? {
                predicate = NSPredicate(format: "%K == %@ AND %K > %@ AND %K < %@",
                                        "city", item,
                                        "date", currentDate as NSDate,
                                        "date", date as NSDate)
            }
        }
        self.fetchRequest.predicate = predicate
    }
    
    // MARK: - Init
    
    init(context: NSManagedObjectContext) {
        super.init(fetchRequest: request,
                   managedObjectContext: context,
                   sectionNameKeyPath: nil,
                   cacheName: nil)
    }
    
    // MARK: - Helper functions
    
}
