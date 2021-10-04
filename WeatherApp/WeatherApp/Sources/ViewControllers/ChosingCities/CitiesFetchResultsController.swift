//
//  CitiesFetchResultsController.swift
//  WeatherApp
//
//  Created by  Buxlan on 10/4/21.
//

import UIKit
import CoreData

class CitiesFetchResultsController: NSFetchedResultsController<City> {
    
    // MARK: - Properties
    typealias ItemType = City
    
    private let request: NSFetchRequest<City> = {
        let request = City.prepareFetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        request.fetchBatchSize = 100
        return request
    }()
    
    // MARK: - Init
    
    init(context: NSManagedObjectContext) {
        super.init(fetchRequest: request,
                   managedObjectContext: context,
                   sectionNameKeyPath: nil,
                   cacheName: "citiesCache")
    }
    
    // MARK: - Helper functions
    func configurePredicate(filter: String) {
        if filter.isEmpty {
            self.fetchRequest.predicate = nil
        } else {
            let predicate = NSPredicate(format: "%K contains[cd] %@", "name", filter)
            self.fetchRequest.predicate = predicate
        }
    }
    
}
