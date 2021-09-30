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
    
    weak var delegate: (NSFetchedResultsControllerDelegate
                        & Navigatable
                        & Updatable
                        & UpdatableCityData)? {
        didSet {
            fetchResultsController.delegate = delegate
        }
    }
    
    var currentCity: CityData? {
        didSet {
            if let currentCity = currentCity {
                DispatchQueue.main.async {
                    self.delegate?.updateCityInfo(data: currentCity)
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
    private lazy var fetchResultsController: NSFetchedResultsController<ItemType> = {
        let fetchRequest = ItemType.prepareFetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "isChosen", NSNumber(true))
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
    
    func update() {
        managedObjectContext.perform {
            do {
                try self.fetchResultsController.performFetch()
                self.delegate?.update()
            } catch {
                print(error)
            }
        }
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
