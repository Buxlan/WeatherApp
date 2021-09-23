//
//  CoreDataManager.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/21/21.
//

import Foundation
import CoreData

class CoreDataManager {
    
    // Singleton
    static let instance = CoreDataManager()
    
    private init() {}
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle(for: Self.self).url(forResource: "WeatherApp",
                                                     withExtension: "momd")?.appendingPathComponent("WeatherApp.mom"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError()
        }
        return model
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("db.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        return coordinator
    }()
    
    lazy var mainObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    lazy var privateObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // Entity for Name
    func entityForName(entityName: String) -> NSEntityDescription {
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: self.mainObjectContext) else {
            fatalError("Cannot get entity City")
        }
        return entity
    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        if mainObjectContext.hasChanges {
            do {
                try mainObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")                
            }
        }
        if privateObjectContext.hasChanges {
            do {
                try privateObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
