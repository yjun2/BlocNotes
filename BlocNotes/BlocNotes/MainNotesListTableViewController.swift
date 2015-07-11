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
    
    var noteFetchResultsController: NSFetchedResultsController!
    var filteredNoteResultsController: NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // fetch all notes first
        fetchAllNotes()
        noteFetchResultsController.delegate = self
        
        // setup search bar
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.active && count(searchController.searchBar.text) > 0 {
            let sectionInfo = filteredNoteResultsController!.sections![section] as! NSFetchedResultsSectionInfo
            return sectionInfo.numberOfObjects
        } else {
            let sectionInfo = noteFetchResultsController!.sections![section] as! NSFetchedResultsSectionInfo
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
    
    // MARK: - Core Data Fetch
    func fetchAllNotes() {
        // setup fetch request
        let noteFetchRequest = NSFetchRequest(entityName: "Note")
        
        // sort the request by dateModified in descending order
        let sortByModifiedDateDescriptor = NSSortDescriptor(key: "dateModified", ascending: false)
        noteFetchRequest.sortDescriptors = [sortByModifiedDateDescriptor]
        
        noteFetchResultsController = NSFetchedResultsController(fetchRequest: noteFetchRequest,
            managedObjectContext: managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        var error: NSError? = nil
        if (!noteFetchResultsController.performFetch(&error)) {
            println("Error: \(error?.description)")
        }
    
    }
    
    // MARK: - DetailViewControllerDelegate
    func detailViewController(controller: DetailViewController, didFinishAddNewNote: Note) {
        fetchAllNotes()
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
        
            var error: NSError? = nil
            if (!filteredNoteResultsController.performFetch(&error)) {
                println("Error: \(error?.description)")
            }
        
            let sectionInfo = filteredNoteResultsController!.sections![0] as! NSFetchedResultsSectionInfo
            println("count: \(sectionInfo.numberOfObjects)")
            
            tableView.reloadData()
        } else {
            fetchAllNotes()
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
