//
//  MainNotesListTableViewController.swift
//  BlocNotes
//
//  Created by Yong Jun on 6/29/15.
//  Copyright (c) 2015 Yong Jun. All rights reserved.
//

import UIKit
import CoreData

class MainNotesListTableViewController: UITableViewController, DetailViewControllerDelegate {

    var managedContext: NSManagedObjectContext!
    var notes = [Note]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchAllNotes()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NoteItem", forIndexPath: indexPath) as! UITableViewCell

        let label = cell.viewWithTag(1000) as! UILabel
        label.text = notes[indexPath.row].title

        return cell
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            // get the reference to the note object to be deleted
            let noteObject = notes[indexPath.row] as Note
            
            // remove from the array first
            notes.removeAtIndex(indexPath.row)
            
            // remove from core data
            managedContext.deleteObject(noteObject)
            
            // commit
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not delete: \(error)")
            }
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addNewNote" {
            let addNewNoteVC = segue.destinationViewController as! DetailViewController
            addNewNoteVC.delegate = self
            addNewNoteVC.managedContext = managedContext
            
            // temporary for user story 1
            addNewNoteVC.noteCount = notes.count
            
        } else if segue.identifier == "editNote" {
            let editNoteVC = segue.destinationViewController as! DetailViewController
            editNoteVC.delegate = self
            editNoteVC.managedContext = managedContext
            
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                editNoteVC.noteToView = notes[indexPath.row]
            }
        }
    }
    
    // MARK: - Core Data Fetch
    func fetchAllNotes() {
        var error: NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "Note")
        
        // sort the request by dateModified in descending order
        let sortByModifiedDateDescriptor = NSSortDescriptor(key: "dateModified", ascending: false)
        fetchRequest.sortDescriptors = [sortByModifiedDateDescriptor]
        
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [Note]?
        if let results = fetchedResults {
            notes = results
        } else {
            println("Could not fetch \(error)")
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
}
