//
//  CoreDataManager.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/21/21.
//

// Path of DB here
// NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)

import Foundation
import CoreData

class CoreDataManager {
    
    // Singleton
    static let shared = CoreDataManager()
        
    private init() {
        managedObjectModel = Self.makeManagedObjectModel()
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        configurePersistentStoreCoordinator(persistentStoreCoordinator)
    }
    
    deinit {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1]
    }()
    
    var managedObjectModel: NSManagedObjectModel
    
    static private func makeManagedObjectModel() -> NSManagedObjectModel {
        guard let modelURL = Bundle.main.url(forResource: "Database",
                                             withExtension: "momd")?.appendingPathComponent("Database.mom"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError()
        }
        return model
    }
    
    var persistentStoreCoordinator: NSPersistentStoreCoordinator
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Database")        
        
        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var mainObjectContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        return context
    }()

    var privateObjectContext: NSManagedObjectContext {
        let context = NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
//        return context
//        let context = persistentContainer.newBackgroundContext()
//        print("privateObjectContext: \(context.persistentStoreCoordinator.debugDescription)")
        return context
    }
    
    // Entity for Name
    func entityForName(entityName: String, context: NSManagedObjectContext?) -> NSEntityDescription {
        guard let context = context,
            let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            fatalError("Cannot get entity with name: \(entityName)")
        }
        return entity
    }
    
    // MARK: - Core Data Saving support   
    func save(_ context: NSManagedObjectContext) throws {
        if !context.hasChanges { return }
        if context != mainObjectContext {
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self,
                                           selector: #selector(managedObjectContextDidSave),
                                           name: NSNotification.Name.NSManagedObjectContextDidSave,
                                           object: context)
        }
        try context.save()
    }
    
    @objc
    private func managedObjectContextDidSave(notification: Notification) {
        let context = CoreDataManager.shared.mainObjectContext
        context.perform {
            context.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
            context.mergeChanges(fromContextDidSave: notification)
            let notificationCenter = NotificationCenter.default
            notificationCenter.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        }        
    }
    
    private func configurePersistentStoreCoordinator(_ coordinator: NSPersistentStoreCoordinator) {
        let url = self.applicationDocumentsDirectory.appendingPathComponent("database.sqlite")
                
        CityDatabaseLoader().copySnapshotIfNeeded()
        
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption as NSObject: true,
                           NSInferMappingModelAutomaticallyOption as NSObject: true]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
    }
}
