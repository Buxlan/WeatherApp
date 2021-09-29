//
//  SelectingCitiesViewModel.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/22/21.
//

import Foundation
import CoreData
import UIKit

class CitiesViewModel: NSObject {
    
    typealias ItemType = City
    typealias CellModelType = MainDataModel
    
    weak var delegate: (NSFetchedResultsControllerDelegate & Updateable)? {
        didSet {
            fetchResultsController.delegate = delegate
        }
    }
    
    private var isLoading: Bool = false
    
    private var managedObjectContext = CoreDataManager.shared.mainObjectContext
    private lazy var fetchResultsController: NSFetchedResultsController<ItemType> = {
        let fetchRequest = City.prepareFetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
//        let predicate = NSPredicate(format: "%K == %@", "order", order)
//        fetchRequest.predicate = predicate
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: managedObjectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = delegate
        return fetchedResultsController
    }()
    // MARK: - Init    
    
    // MARK: - Helper functions
    func update(with filter: String = "") {
        if filter.isEmpty {
            fetchResultsController.fetchRequest.predicate = nil
        } else {
            let predicate = NSPredicate(format: "%K contains[cd] %@", "name", filter)
            fetchResultsController.fetchRequest.predicate = predicate
        }
        managedObjectContext.perform {
            do {
                try self.fetchResultsController.performFetch()
                print("perform fetch")
                self.delegate?.update()
            } catch {
                print(error)
            }
        }
    }
    
    func cellModel(at indexPath: IndexPath) -> CellModelType {
        let item = self.item(at: indexPath)
        let text = item.name
        let detailText = String(format: "Lat: %.6f, Lon: %.6f", item.coord.latitude, item.coord.longitude)
        let cellModel = CellModelType(text: text, detailText: detailText)
        return cellModel
    }
    
    func item(at indexPath: IndexPath) -> ItemType {
        fetchResultsController.object(at: indexPath)
    }
    
    var itemsCount: Int {
        fetchResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func selectItem(at indexPath: IndexPath) {
        let item = self.item(at: indexPath)
        item.isChosen = !item.isChosen
        let context = CoreDataManager.shared.mainObjectContext
        CoreDataManager.shared.save(context)
    }
    
    func save() {
        DispatchQueue.global(qos: .userInteractive).async {
            CurrentWeatherManager.shared.update()
        }
    }        
}

extension CitiesViewModel: Observer {
    
    func notify() {
        self.update()
    }
    
}
