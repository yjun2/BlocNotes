//
//  CoreDataStack2.swift
//  BlocNotes
//
//  Created by Yong Jun on 7/15/15.
//  Copyright (c) 2015 Yong Jun. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("BlocNotes", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    
        // access core data mode in share extension
        let storeUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.bloc.notes")
        let url = storeUrl?.URLByAppendingPathComponent("BlocNotes.sqlite")
    
        let storeOptions = [NSPersistentStoreUbiquitousContentNameKey: "BlocNotes",
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true]
        
        var error: NSError? = nil
        let store: NSPersistentStore? = coordinator!.addPersistentStoreWithType(NSSQLiteStoreType,
            configuration: nil,
            URL: url,
            options: storeOptions,
            error: &error)
        
        if store == nil {
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
            
        return coordinator
    }()
    
    func getCoreDataContext() -> NSManagedObjectContext {
        return self.managedObjectContext!
    }
    
    func saveContext () {
        var error: NSError? = nil
        if managedObjectContext!.hasChanges && !managedObjectContext!.save(&error) {
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
}
