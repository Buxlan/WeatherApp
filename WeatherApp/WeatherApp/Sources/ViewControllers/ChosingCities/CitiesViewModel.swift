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
    
    weak var delegate: (NSFetchedResultsControllerDelegate & Updatable)? {
        didSet {
            resultsController.delegate = delegate
        }
    }
    
    private var isLoading: Bool = false
    
    private var managedObjectContext = CoreDataManager.shared.mainObjectContext
    private lazy var resultsController: CitiesFetchResultsController = {
        let resultsController = CitiesFetchResultsController(context: managedObjectContext)
        resultsController.delegate = delegate
        return resultsController
    }()
    // MARK: - Init    
    
    // MARK: - Helper methods
    func update(with filter: String = "") {
        resultsController.configurePredicate(filter: filter)
        managedObjectContext.perform {
            do {
                try self.resultsController.performFetch()
                self.delegate?.updateUserInterface()
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
        resultsController.object(at: indexPath)
    }
    
    var itemsCount: Int {
        resultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func selectItem(at indexPath: IndexPath) {
        let item = self.item(at: indexPath)
        item.isChosen = !item.isChosen
    }
    
    func save() {
        managedObjectContext.perform {
            do {
                try CoreDataManager.shared.save(self.managedObjectContext)
                DispatchQueue.global(qos: .userInteractive).async {
                    WeatherManager.shared.update()
                }
                AppController.shared.isFirstLaunch = false
            } catch {
                print(error)
            }
        }        
    }    
}

extension CitiesViewModel: Observer {
    
    func notify() {
        self.update()
    }
    
}
