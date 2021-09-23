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
    var condition: Condition = .none
    var updateAction: (() -> Void)?
    
    private var items: [City] {
        didSet {
            updateAction?()
        }
    }
    
    init(with condition: Condition = .none) {
        items = [City]()
        self.condition = condition
    }
    
    func update(with condition: Condition? = nil) {
        if let condition = condition {
            self.condition = condition
        }
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else {
                return
            }
            let context = CoreDataManager.instance.privateObjectContext
            context.performAndWait {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "City")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
                switch self.condition {
                case .bool(let value):
                    fetchRequest.predicate = NSPredicate(format: "selected == %@", NSNumber(value: value))
                case .string(let value):
                    fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", NSString(string: value))
                case .none:
                    fetchRequest.predicate = nil
                }
                do {
                    guard let results = try CoreDataManager.instance.mainObjectContext.fetch(fetchRequest) as? [City] else {
                        return
                    }
                    self.items = results
                } catch {
                    print(error)
                }
            }
            
        }
    }
        
    func item(at indexPath: IndexPath) -> Item {
        if indexPath.row > itemsCount {
            return Item()
        }
        return items[indexPath.row]
    }
    
    var itemsCount: Int {
        items.count
    }
    
    func selectItem(at indexPath: IndexPath) {
        let item = items[indexPath.row]
        item.setSelected(value: !item.selected)
    }
}
