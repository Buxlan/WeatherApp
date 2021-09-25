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
            WeatherManager.shared.addObserver(self)
        }
    }
    var updateAction: (() -> Void)?
    
    private lazy var fetchResultsController: NSFetchedResultsController<Item> = {
        let fetchRequest = ChoosedCity.prepareFetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "city.name", ascending: true)
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
    
    func update(with condition: Condition? = nil) {
        let context = fetchResultsController.managedObjectContext
        self.prepareCitiesIfNeeded()
        context.perform {
            do {
                try self.fetchResultsController.performFetch()
                self.updateAction?()
            } catch {
                print(error)
            }
        }
    }
    
    private func prepareCitiesIfNeeded() {
        DispatchQueue.global(qos: .userInteractive).async {
            if !AppController.shared.areCitiesLoaded {
                CityManager.initCitiesFromFile()
                self.update()
            }
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
    
    deinit {
        WeatherManager.shared.removeObserver(self)
    }
}

extension MainViewModel: Observer {
    
    func notify() {
        self.update()
    }
    
}
