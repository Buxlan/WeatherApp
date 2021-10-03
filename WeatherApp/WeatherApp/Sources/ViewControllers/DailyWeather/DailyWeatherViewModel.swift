//
//  DailyWeatherViewModel.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/25/21.
//

import Foundation
import CoreData

class DailyWeatherViewModel: NSObject {
    
    typealias ItemType = DailyWeather
    typealias ItemTypeData = DailyWeatherDataModel
    
    var city: City? {
        didSet {
            resultsController.predicateItem = city
        }        
    }
    
    weak var delegate: (NSFetchedResultsControllerDelegate
                        & Updatable
                        & ViewModelStateDelegate)? {
        didSet {
            resultsController.delegate = delegate
        }
    }
    
    var isViewModelLoading: Bool = false {
        didSet {
            switch isViewModelLoading {
            case true:
                delegate?.didChangeTableViewState(new: .loading)
            default:
                delegate?.didChangeTableViewState(new: .normal)
            }
        }
    }
    
    private var managedObjectContext = CoreDataManager.shared.mainObjectContext
    private lazy var resultsController: DailyWeatherResultsController = {
        let resultsController = DailyWeatherResultsController(context: managedObjectContext)
        resultsController.delegate = delegate
        resultsController.predicateItem = city
        return resultsController
    }()
    // MARK: - Init
    
    // MARK: - Helper methods
    
    func reloadData() {
        guard delegate != nil else {
            return
        }
        managedObjectContext.perform {
            do {
                self.isViewModelLoading = true
                try self.resultsController.performFetch()
                self.delegate?.updateUserInterface()
                self.isViewModelLoading = false
            } catch {
                print(error)
            }
        }
    }    
    
    var numberOfSections: Int {
        resultsController.sections?.count ?? 0
    }
    
    func itemData(at indexPath: IndexPath) -> ItemTypeData {
        transform(from: resultsController.object(at: indexPath))
    }
    
    private func item(at indexPath: IndexPath) -> ItemType {
        resultsController.object(at: indexPath)
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        resultsController.sections?[section].numberOfObjects ?? 0
    }
    
    private func transform(from item: ItemType?) -> ItemTypeData {
        guard let item = item else {
            return ItemTypeData()
        }
        let data = DailyWeatherData(data: item)
        return ItemTypeData(data: data)
    }
}
