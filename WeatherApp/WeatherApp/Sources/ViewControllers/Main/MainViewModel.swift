//
//  MainViewModel.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/22/21.
//

import Foundation
import CoreData
import UIKit

class MainViewModel: NSObject {
    
    typealias ItemType = City
    typealias CellModelType = MainDataModel
        
    weak var delegate: (Navigatable
                        & Updatable
                        & CurrentCityDelegate)?
    
    var currentCity: CityData? {
        didSet {
            if let currentCity = currentCity {
                DispatchQueue.main.async {
                    self.delegate?.didChangeCurrentCity(new: currentCity)
                }
            }
        }
    }
    
    private var locationManager: LocationManager?
    func performDetermingCurrentCity() {
        DispatchQueue.main.async {
            if self.locationManager == nil {
                let manager = LocationManager()
                manager.delegate = self
                self.locationManager = manager
            }
            self.locationManager?.performLocateCity()            
        }
        
    }
    
    private var isLoading: Bool = false
    
    private var managedObjectContext = CoreDataManager.shared.mainObjectContext
    private var currentCityCompletionHandler: ((CityData?) -> Void)?
    private lazy var fetchResultsController: NSFetchedResultsController<ItemType> = {
        let fetchRequest = ItemType.prepareFetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "isChosen", NSNumber(true))
        fetchRequest.sortDescriptors = [sortDescriptor]
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: managedObjectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        controller.delegate = self
        return controller
    }()
    // MARK: - Init    
    
    // MARK: - Helper methods
    
    func update() {
        managedObjectContext.perform {
            do {
                try self.fetchResultsController.performFetch()
                self.delegate?.update()
            } catch {
                print(error)
            }
        }
        let handler: ((CityData?) -> Void) = { [weak self] cityData in
            guard let self = self else {
                return
            }
            self.currentCity = cityData
        }
        currentCityCompletionHandler = handler
        CityManager.shared.requestCurrentCity(completionHandler: handler)
    }
    
    func cellModel(at indexPath: IndexPath) -> CellModelType {
        let item = self.item(at: indexPath)
        let text = item.name
        let detailText = "\(item.currentWeather?.temp ?? 0.0)"
        let cellModel = CellModelType(text: text, detailText: detailText)
        return cellModel
    }
    
    func item(at indexPath: IndexPath) -> ItemType {
        fetchResultsController.object(at: indexPath)
    }
    
    var itemsCount: Int {
        fetchResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func prepareNavigation(to viewController: UIViewController, _ indexPath: IndexPath) {
        if let viewController = viewController as? DailyWeatherViewController {
            let city = item(at: indexPath)
            viewController.city = city
        }
    }
}

extension MainViewModel: LocationManagerDelegate {
    
    func didUpdateCurrentCity(_ cityData: CityData) {
        currentCity = cityData
    }
    
}

extension MainViewModel: NSFetchedResultsControllerDelegate {
        
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.update()
    }
}
