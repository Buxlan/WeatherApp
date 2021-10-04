//
//  MainFetchResultsController.swift
//  WeatherApp
//
//  Created by  Buxlan on 10/3/21.
//

import UIKit
import CoreData

class MainFetchResultsController: NSFetchedResultsController<City> {
    
    // MARK: - Properties
    typealias ItemType = City
    
    private let request: NSFetchRequest<City> = {
        let request = ItemType.prepareFetchRequest()
        request.predicate = NSPredicate(format: "%K == %@ OR %K == %@",
                                        "isChosen",
                                        NSNumber(true),
                                        "isCurrent",
                                        NSNumber(true))
        request.sortDescriptors = [NSSortDescriptor(key: "isCurrent", ascending: false),
                                   NSSortDescriptor(key: "name", ascending: true)]
        request.fetchBatchSize = 30
        return request
    }()
    
    // MARK: - Init
    
    init(context: NSManagedObjectContext) {
        super.init(fetchRequest: request,
                   managedObjectContext: context,
                   sectionNameKeyPath: "isCurrent",
                   cacheName: nil)
    }
    
    // MARK: - Helper functions
    
}
