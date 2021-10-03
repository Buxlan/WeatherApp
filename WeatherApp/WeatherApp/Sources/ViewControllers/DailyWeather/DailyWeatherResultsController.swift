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
        request.sortDescriptors = [NSSortDescriptor(key: "isCurrent", ascending: false),
                                   NSSortDescriptor(key: "name", ascending: true)]
        request.fetchBatchSize = 30
        return request
    }()
    
    private func configurePredicate() {
        var predicate: NSPredicate?
        if let item = predicateItem {
            predicate = NSPredicate(format: "%K == %@", "city", item)
        }
        self.fetchRequest.predicate = predicate
    }
    
    // MARK: - Init
    
    init(context: NSManagedObjectContext) {
        super.init(fetchRequest: request,
                   managedObjectContext: context,
                   sectionNameKeyPath: "isCurrent",
                   cacheName: nil)
    }
    
    // MARK: - Helper functions
    
}

extension DailyWeatherResultsController: NSFetchedResultsControllerDelegate {
    
    
    
}
