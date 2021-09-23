//
//  MainViewModel.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/22/21.
//

import Foundation
import CoreData

class MainViewModel {
    
    typealias Item = City
    
    var updateAction: (() -> Void)? {
        didSet {
            updateItems()
        }
    }
    
    private var items: [City] {
        didSet {
            updateAction?()
            WeatherManager.shared.updateWeather(cities: items)
        }
    }
    
    init() {
        items = [City]()
    }
    
    func updateItems() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else {
                return
            }
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "City")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            fetchRequest.predicate = NSPredicate(format: "selected == YES")
            do {
                guard let results = try CoreDataManager.instance.mainObjectContext.fetch(fetchRequest) as? [Item] else {
                    return
                }
                self.items = results
            } catch {
                print(error)
            }
        }
    }    
    
    func item(at indexPath: IndexPath) -> Item {
        return items[indexPath.row]
    }
    
    var itemsCount: Int {
        items.count
    }    
}
