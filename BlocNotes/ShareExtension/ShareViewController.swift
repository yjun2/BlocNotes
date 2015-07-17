//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Yong Jun on 7/6/15.
//  Copyright (c) 2015 Yong Jun. All rights reserved.
//

import UIKit
import Social
import CoreData
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {
    
    lazy var managedContext = CoreDataStack().getCoreDataContext()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Listen for NSPersistentStoreDidImportUbiquitousContentChangesNotification notification when
        // updates have been applied to data
//        NSNotificationCenter.defaultCenter().addObserver(self,
//            selector: "respondToICloudChanges:",
//            name: NSPersistentStoreDidImportUbiquitousContentChangesNotification,
//            object: self.managedContext.persistentStoreCoordinator)

    }
    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        NSNotificationCenter.defaultCenter().removeObserver(self,
//            name: NSPersistentStoreDidImportUbiquitousContentChangesNotification,
//            object:
//            self.managedContext.persistentStoreCoordinator)
//    }
    
    // MARK: - iCloud changes
//    func respondToICloudChanges(notification: NSNotification) {
//        println("merging iCloud share extension content changes")
//        self.managedContext.performBlock { () -> Void in
//            self.managedContext.mergeChangesFromContextDidSaveNotification(notification)
//        }
//    }
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        addNewNote()
        self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
    }

    override func configurationItems() -> [AnyObject]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    func addNewNote() -> Note? {
        var tmpNote: Note? = nil
        
        let noteEntity = NSEntityDescription.entityForName("Note", inManagedObjectContext: managedContext)
        let note = Note(entity: noteEntity!, insertIntoManagedObjectContext: managedContext)
        
        println("contentText: \(contentText)")
        note.title = contentText
        note.dateCreated = NSDate()
        note.dateModified = NSDate()
            
        let contentEntity = NSEntityDescription.entityForName("Content", inManagedObjectContext: managedContext)
        let content = Content(entity: contentEntity!, insertIntoManagedObjectContext: managedContext)
        
        content.body = "Test test test"
        note.content = content
            
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save: \(error)")
        } else {
            println("A new note saved")
            tmpNote = note
        }
        
        return tmpNote
    }

}
