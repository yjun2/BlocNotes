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
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
//        addNewNote()
        
        var inputItem = self.extensionContext?.inputItems.first as! NSExtensionItem
        var provider = inputItem.attachments?.first as! NSItemProvider
        if provider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
            provider.loadItemForTypeIdentifier(kUTTypeURL as String,
                options: nil,
                completionHandler: { (item, error) -> Void in
                    if let x = item as? NSURL {
                        var urlString = x.absoluteString
                        println("urlString: \(urlString)")
                    }
            })
        }
        
        self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
    }

    override func configurationItems() -> [AnyObject]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    func addNewNote() -> Note? {
        var tmpNote: Note? = nil
        var coreDataStack = CoreDataStack.sharedInstance
        let managedContext = coreDataStack.getCoreDataContext()
        
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
