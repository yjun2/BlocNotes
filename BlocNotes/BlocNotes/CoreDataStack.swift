//
//  CoreStack.swift
//  BlocNotes
//
//  Created by Yong Jun on 7/8/15.
//  Copyright (c) 2015 Yong Jun. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    static let sharedInstance = CoreDataStack()
    
    private let managedObjectContext: NSManagedObjectContext
    private let managedObjectModel: NSManagedObjectModel
    private let persistentStoreCoordinator: NSPersistentStoreCoordinator
    
    private init() {
        
        let modelURL = NSBundle.mainBundle().URLForResource("BlocNotes", withExtension: "momd")!
        managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)!
        managedObjectContext = NSManagedObjectContext()
        
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        let storeUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.bloc.notes")
        let url = storeUrl?.URLByAppendingPathComponent("BlocNotes.sqlite")
        
        var error: NSError? = nil
        let store: NSPersistentStore? = persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType,
            configuration: nil,
            URL: url,
            options: nil,
            error: &error)
        
        if store == nil {
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }

    }
    
    func getCoreDataContext() -> NSManagedObjectContext {
        return self.managedObjectContext
    }
    
    func saveContext () {
        var error: NSError? = nil
        if managedObjectContext.hasChanges && !managedObjectContext.save(&error) {
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    // MARK: - Private methods

//    private func sharedCoreData() -> NSURL {
//        let storeUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(APP_GROUP_ID)
//        let url = storeUrl?.URLByAppendingPathComponent(SQLITE_NAME)
//        return url!
//    }
//    
//    private func getManagedObjectContext(psc: NSPersistentStoreCoordinator) -> NSManagedObjectContext? {
//        var managedObjectContext = NSManagedObjectContext()
//        managedObjectContext.persistentStoreCoordinator = psc
//        return managedObjectContext
//    }
//    
//    private func addPersistentStoreType(psc: NSPersistentStoreCoordinator) -> NSPersistentStoreCoordinator? {
//        
//        let url = sharedCoreData()
//        
//        var error: NSError? = nil
//        if psc.addPersistentStoreWithType(NSSQLiteStoreType,
//                                                    configuration: nil,
//                                                    URL: url,
//                                                    options: nil,
//                                                    error: &error) == nil {
//            // Report any error we got.
//            var dict = [String: AnyObject]()
//            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
//            dict[NSLocalizedFailureReasonErrorKey] = failureReason
//            dict[NSUnderlyingErrorKey] = error
//            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
//            
//            NSLog("Unresolved error \(error), \(error!.userInfo)")
//            abort()
//        }
//        
//        return psc
//    }
}