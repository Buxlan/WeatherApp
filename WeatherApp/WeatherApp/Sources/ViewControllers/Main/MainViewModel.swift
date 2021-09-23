//
//  MainViewModel.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/22/21.
//

import Foundation
import CoreData

class MainViewModel {
    
    typealias Item = ChoosedCity
    
    weak var delegate: NSFetchedResultsControllerDelegate? {
        didSet {
            fetchResultsController.delegate = delegate
        }
    }
    
    private lazy var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ChoosedCity")
        let sortDescriptor = NSSortDescriptor(key: "coty.name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
//        let predicate = NSPredicate(format: "%K == %@", "order", order)
//        fetchRequest.predicate = predicate
        let context = CoreDataManager.instance.privateObjectContext
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)        
        return fetchedResultsController
    }()
    
    func update(with condition: Condition? = nil) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else {
                return
            }
            CoreDataManager.instance.mainObjectContext.performAndWait {
                self.prepareCitiesIfNeeded()
            }
            let context = CoreDataManager.instance.privateObjectContext
            context.perform {
                do {
                    try self.fetchResultsController.performFetch()
                } catch {
                    print(error)
                }
            }
            
        }
    }
    
    @discardableResult
    private func prepareCitiesIfNeeded() -> Bool {
        var isOk = true
        // Load cities
        if !AppController.shared.areCitiesLoaded {
            isOk = CityManager.initCitiesFromFile()
            if isOk {
                AppController.shared.areCitiesLoaded = true
            }
        }
        return isOk
    }
    
    func item(at indexPath: IndexPath) -> Item {
        if let item = fetchResultsController.object(at: indexPath) as? Item {
            return item
        }
        return Item()
    }
    
    var itemsCount: Int {
        if let count = fetchResultsController.sections?[0].numberOfObjects {
            return count
        }
        return 0
    }
}
