//
//  SelectingCitiesViewModel.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/22/21.
//

import Foundation
import CoreData

enum Condition {
    case bool(Bool)
    case string(String)
    case none
}

class CitiesViewModel {
    
    typealias Item = City
    
    private var fitler: String = ""
    
    weak var delegate: NSFetchedResultsControllerDelegate? {
        didSet {
            fetchResultsController.delegate = delegate
        }
    }
    var updateAction: (() -> Void)?
    
    private lazy var fetchResultsController: NSFetchedResultsController<Item> = {
        let fetchRequest = City.prepareFetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
//        let predicate = NSPredicate(format: "%K == %@", "order", order)
//        fetchRequest.predicate = predicate
        let context = CoreDataManager.instance.mainObjectContext
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        return fetchedResultsController
    }()
    
    func update(filter: String = "") {
        if filter.isEmpty {
            fetchResultsController.fetchRequest.predicate = nil
        } else {
            let predicate = NSPredicate(format: "name CONTAINS[cd] %@", filter)
            fetchResultsController.fetchRequest.predicate = predicate
        }
        do {
            try self.fetchResultsController.performFetch()
            self.updateAction?()
        } catch {
            print(error)
        }
    }
    
    func item(at indexPath: IndexPath) -> Item {
        return fetchResultsController.object(at: indexPath)
    }
    
    var itemsCount: Int {
        if let count = fetchResultsController.sections?[0].numberOfObjects {
            return count
        }
        return 0
    }
    
    func selectItem(at indexPath: IndexPath) {
        let item = self.item(at: indexPath)
        let manager = CoreDataManager.instance
        let mainContext = manager.mainObjectContext
        let privateContext = manager.privateObjectContext
        if let selected = item.selected {
            mainContext.delete(selected)
            item.selected = nil
        } else {
            let choosedCity = ChoosedCity(insertInto: mainContext)
            item.selected = choosedCity
            mainContext.perform {
                do {
                    try mainContext.save()
                    if let selectedNew = try privateContext.existingObject(with: choosedCity.objectID) as? ChoosedCity {
                        WeatherManager.shared.updateCurrentWeather(at: selectedNew, in: privateContext)
                    }
                } catch {
                    print("error saving")
                }
            }
        }
    }
    
    func save() {
        CoreDataManager.instance.save(CoreDataManager.instance.mainObjectContext)
    }
    
//    func prepareFetchResultsController() -> NSFetchedResultsController<Item> {
//        let fetchRequest = City.fetchRequest(filter: self.fitler)
//        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptor]
////        let predicate = NSPredicate(format: "%K == %@", "order", order)
////        fetchRequest.predicate = predicate
//        let context = CoreDataManager.instance.privateObjectContext
//        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
//                                                                  managedObjectContext: context,
//                                                                  sectionNameKeyPath: nil,
//                                                                  cacheName: nil)
//        return fetchedResultsController
//    }
}
