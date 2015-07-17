//
//  MainNotesListTableViewController.swift
//  BlocNotes
//
//  Created by Yong Jun on 6/29/15.
//  Copyright (c) 2015 Yong Jun. All rights reserved.
//

import UIKit
import CoreData

class MainNotesListTableViewController: UITableViewController, DetailViewControllerDelegate, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {

    let searchController = UISearchController(searchResultsController: nil)
    var managedContext: NSManagedObjectContext!
    
    var error: NSError? = nil

    var filteredNoteResultsController: NSFetchedResultsController!
    
    lazy var noteFetchResultsController : NSFetchedResultsController = {
        let request = NSFetchRequest(entityName: "Note")
        request.sortDescriptors = [NSSortDescriptor(key: "dateModified", ascending: false)]
        
        let noteFetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.managedContext, sectionNameKeyPath: nil, cacheName: nil)
        noteFetchResultsController.delegate = self
        return noteFetchResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // fetch all notes first
        noteFetchResultsController.performFetch(&error)
        
        // setup search bar
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Listen for NSPersistentStoreDidImportUbiquitousContentChangesNotification notification when
        // updates have been applied to data
        // NSPersistentStoreDidImportUbiquitousContentChangesNotification
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "respondToICloudChanges:",
            name: NSPersistentStoreDidImportUbiquitousContentChangesNotification,
            object: self.managedContext.persistentStoreCoordinator)
        
        //NSPersistentStoreCoordinatorStoresWillChangeNotification
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "persistenWillChange:",
            name: NSPersistentStoreCoordinatorStoresWillChangeNotification,
            object: self.managedContext.persistentStoreCoordinator)
        
        // NSPersistentStoreCoordinatorStoresDidChangeNotification
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "persistentDidChange:",
            name: NSPersistentStoreCoordinatorStoresDidChangeNotification,
            object: self.managedContext.persistentStoreCoordinator)
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: NSPersistentStoreDidImportUbiquitousContentChangesNotification,
            object:
            self.managedContext.persistentStoreCoordinator)
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: NSPersistentStoreCoordinatorStoresWillChangeNotification,
            object:
            self.managedContext.persistentStoreCoordinator)
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: NSPersistentStoreCoordinatorStoresDidChangeNotification,
            object:
            self.managedContext.persistentStoreCoordinator)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - iCloud changes
    func respondToICloudChanges(notification: NSNotification) {
        println("merging iCloud content changes")
        self.managedContext.performBlock { () -> Void in
            self.managedContext.mergeChangesFromContextDidSaveNotification(notification)
            self.tableView.reloadData()
        }
    }
    
    // The persistent coordinator is adding or removing a persistent store
    func persistentWillChange(notification: NSNotification) {
        self.managedContext.performBlock { () -> Void in
            if self.managedContext.hasChanges {
                if self.managedContext.save(&self.error) == false {
                    println("Error saving \(self.error)")
                }
            }
            
            self.managedContext.reset()
        }
    }
    
    // The persistent coordinator is ready for new data
    func persistentDidChange(notification: NSNotification) {
        noteFetchResultsController.performFetch(&error)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.active && count(searchController.searchBar.text) > 0 {
            let sectionInfo = filteredNoteResultsController!.sections![section] as! NSFetchedResultsSectionInfo
            return sectionInfo.numberOfObjects
        } else {
            let sectionInfo = noteFetchResultsController.sections![section] as! NSFetchedResultsSectionInfo
            return sectionInfo.numberOfObjects
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NoteItem", forIndexPath: indexPath) as! UITableViewCell

        let label = cell.viewWithTag(1000) as! UILabel
        
        if searchController.active && count(searchController.searchBar.text) > 0 {
            let note = filteredNoteResultsController.objectAtIndexPath(indexPath) as! Note
            label.text = note.title
        } else {
            let note = noteFetchResultsController.objectAtIndexPath(indexPath) as! Note
            label.text = note.title
        }

        return cell
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            if searchController.active && count(searchController.searchBar.text) > 0 {
                managedContext.deleteObject(filteredNoteResultsController.objectAtIndexPath(indexPath) as! Note)
            } else {
                // remove from core data
                managedContext.deleteObject(noteFetchResultsController.objectAtIndexPath(indexPath) as! Note)
            }
            
            // commit
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not delete: \(error)")
            }
        }
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addNewNote" {
            let addNewNoteVC = segue.destinationViewController as! DetailViewController
            addNewNoteVC.delegate = self
            addNewNoteVC.managedContext = managedContext
            
        } else if segue.identifier == "editNote" {
            let editNoteVC = segue.destinationViewController as! DetailViewController
            editNoteVC.delegate = self
            editNoteVC.managedContext = managedContext
            
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                if searchController.active {
                    editNoteVC.noteToView = filteredNoteResultsController.objectAtIndexPath(indexPath) as? Note
                    searchController.active = false
                } else {
                    editNoteVC.noteToView = noteFetchResultsController.objectAtIndexPath(indexPath) as? Note
                }
                
                
            }
        }
    }
    
    // MARK: - DetailViewControllerDelegate
    func detailViewController(controller: DetailViewController, didFinishAddNewNote: Note) {
        noteFetchResultsController.performFetch(&error)
        tableView.reloadData()
    }
    
    func detailViewControllerDidNoTextEntered(controller: DetailViewController) {
        controller.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - SearchResultsUpdating 
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        println("searchbar text entered: \(searchController.searchBar.text)")
        
        if count(searchController.searchBar.text) > 0 {
            let noteFetchRequest = NSFetchRequest(entityName: "Note")
        
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", searchController.searchBar.text)
            let contentPredicate = NSPredicate(format: "content.body CONTAINS[c] %@", searchController.searchBar.text)
            
            let notePredicate = NSCompoundPredicate(type: .OrPredicateType, subpredicates: [titlePredicate, contentPredicate])
            noteFetchRequest.predicate = notePredicate
        
            let sortByModifiedDateDescriptor = NSSortDescriptor(key: "title", ascending: true)
            noteFetchRequest.sortDescriptors = [sortByModifiedDateDescriptor]
            
            filteredNoteResultsController = NSFetchedResultsController(fetchRequest: noteFetchRequest,
                managedObjectContext: managedContext,
                sectionNameKeyPath: nil,
                cacheName: nil)
        
            if (!filteredNoteResultsController.performFetch(&error)) {
                println("Error: \(error?.description)")
            }
        
            let sectionInfo = filteredNoteResultsController!.sections![0] as! NSFetchedResultsSectionInfo
            println("count: \(sectionInfo.numberOfObjects)")
            
            tableView.reloadData()
        } else {
            noteFetchResultsController.performFetch(&error)
            tableView.reloadData()
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        default:
            break
        }
    }
    
}
