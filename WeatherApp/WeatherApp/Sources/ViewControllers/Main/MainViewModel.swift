//
//  MainViewModel.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/22/21.
//

import Foundation
import CoreData
import UIKit

enum UserInterfaceStatus {
    case normal
    case loading
}

class MainViewModel: NSObject {
    
    typealias ItemType = City
    typealias ItemTypeData = CityData
    typealias CellDataType = MainDataModel
    typealias SectionDataType = MainDataModel
        
    weak var delegate: (NSFetchedResultsControllerDelegate
                        & Navigatable
                        & Updatable
                        & ViewModelStateDelegate
                        & ViewStateDelegate)? {
        didSet {
            resultsController.delegate = delegate
        }
    }
    
    private var locationManager: LocationManager = LocationManager()
    
    private var isLocationLoading: Bool = false {
        didSet {
            if isLocationLoading {
                delegate?.didChangeViewState(.loading)
            } else {
                delegate?.didChangeViewState(.normal)
            }
        }
    }
    
    var isViewModelLoading: Bool = false {
        didSet {
            if isViewModelLoading {
                delegate?.didChangeTableViewState(.loading)
            } else {
                delegate?.didChangeTableViewState(.normal)
            }
        }
    }
    
    private var managedObjectContext = CoreDataManager.shared.mainObjectContext
    private lazy var resultsController: MainFetchResultsController = {
        let resultsController = MainFetchResultsController(context: managedObjectContext)
        resultsController.delegate = delegate
        return resultsController
    }()
    
    // MARK: - Init
    
    // MARK: - Helper methods
    
    private var currentCityCompletionHandler: (() -> Void)?
    
    func performDeterminingCurrentCity() {
        if currentCityCompletionHandler != nil {
            // still searching current city
            return
        }
        let handler: () -> Void = { [weak self] in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                self.isLocationLoading = false
                self.currentCityCompletionHandler = nil
            }
        }
        isLocationLoading = true
        currentCityCompletionHandler = handler
        locationManager.performLocating(completionHandler: handler)
    }
    
    func reloadData() {
        guard let delegate = delegate else {
            return
        }
        managedObjectContext.perform {
            do {
                self.isViewModelLoading = true
                try self.resultsController.performFetch()
                delegate.updateUserInterface()
                self.isViewModelLoading = false
            } catch {
                print(error)
            }
        }
    }
    
    func cellData(at indexPath: IndexPath) -> CellDataType {
        let item = self.item(at: indexPath)
        let text = item.name
        let detailText = "\(item.currentWeather?.temp ?? 0.0)"
        let cellModel = CellDataType(text: text, detailText: detailText)
        return cellModel
    }
    
    var numberOfSections: Int {
        resultsController.sections?.count ?? 0
    }
    
    // TODO: ??
    func sectionData(section: Int) -> SectionDataType {
        guard let sections = resultsController.sections,
              sections.count > 0 else {
            return SectionDataType(text: "", detailText: nil)
        }
        
        if let sectionName = resultsController.sections?[section].name {
            switch sectionName {
            case "0":
                return SectionDataType(text: L10n.City.chosenCities,
                                       detailText: nil)
            case "1":
                return SectionDataType(text: L10n.City.yourCityTitle,
                                       detailText: nil)
            default:
                fatalError("Section with name \(sectionName) not found")
            }
        }
        fatalError("Section with index \(section) not found")
    }
    
    func itemData(at indexPath: IndexPath) -> ItemTypeData {
        // TODO: ??
        transform(from: resultsController.object(at: indexPath))
    }
    
    private func item(at indexPath: IndexPath) -> ItemType {
        resultsController.object(at: indexPath)
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        resultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func prepareSegue(to viewController: UIViewController, _ indexPath: IndexPath) {
        if let viewController = viewController as? DailyWeatherViewController {
            let city = item(at: indexPath)
            viewController.city = city
        }
    }
    
    func deleteItem(at indexPath: IndexPath) {
        managedObjectContext.perform {
            let item = self.item(at: indexPath)
            item.isChosen = false
            do {
                try CoreDataManager.shared.save(self.managedObjectContext)
            } catch {
                print(error)
            }
        }
    }
    
    private func transform(from item: ItemType?) -> ItemTypeData {
        guard let item = item else {
            return ItemTypeData()
        }
        return ItemTypeData(city: item)
    }    
    
}
