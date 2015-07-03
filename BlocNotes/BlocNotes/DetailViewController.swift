//
//  DetailViewControllerDelegate
//  BlocNotes
//
//  Created by Yong Jun on 6/30/15.
//  Copyright (c) 2015 Yong Jun. All rights reserved.
//

import UIKit
import CoreData

protocol DetailViewControllerDelegate: class {
    func detailViewControllerDidNoTextEntered(controller: DetailViewController)
    func detailViewController(controller: DetailViewController, didFinishAddNewNote: Note)
}

class DetailViewController: UIViewController, UITextViewDelegate {
    let PLACEHOLDER_TEXT = "Write your note..."
    var managedContext: NSManagedObjectContext!
    var noteToView: Note?
    var noteCount = 0
    
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var noteTitle: UILabel!
    
    weak var delegate: DetailViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let existingNote = noteToView {
            title = existingNote.title
            noteTitle.text = existingNote.title
            bodyTextView.text = existingNote.content.body
        } else {
            initializePlaceHolderText(bodyTextView, placeholder: PLACEHOLDER_TEXT)
        }
        
        bodyTextView.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        save()
    }
    
    @IBAction func done(sender: AnyObject) {
        save()
    }
    
    // Mark: UITextViewDelegate
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if textView == bodyTextView && textView.text == PLACEHOLDER_TEXT {
            
            // Delete the placeholder text
            textView.text = ""
            
            // Change the text color to normal dark color
            textView.textColor = UIColor.darkTextColor()
        }
        
        return true
    }
    
    // Mark: Private methods
    func initializePlaceHolderText(aTextView: UITextView, placeholder: String) {
        aTextView.textColor = UIColor.grayColor()
        aTextView.text = placeholder
    }
    
    func save() {
        let note: Note?
        
        if let existingNote = noteToView {
            note = updateNote(existingNote)
        } else {
            note = addNewNote()
            if let newNote = note {
                noteToView = newNote
            }
        }
        
        if let note = note {
            delegate?.detailViewController(self, didFinishAddNewNote: note)
        }
    }
    
    func updateNote(note: Note) -> Note? {
        // should be able update the note title in user story 2
        
        // update the dateModified
        note.dateModified = NSDate()
        
        // update the note content body
        note.content.body = bodyTextView.text
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save: \(error)")
            return nil
        } else {
            println("Note updated")
            return note
        }
    }
    
    func addNewNote() -> Note? {
        var tmpNote: Note? = nil
        
        if count(bodyTextView.text) > 0 && bodyTextView.text != PLACEHOLDER_TEXT {
            let noteEntity = NSEntityDescription.entityForName("Note", inManagedObjectContext: managedContext)
            let note = Note(entity: noteEntity!, insertIntoManagedObjectContext: managedContext)
        
            // temporarily setting the note title this way.
            // note title will be changed to UITextField in user story 2
            note.title = "\(noteTitle.text!)_\(noteCount++)"
        
            note.dateCreated = NSDate()
            note.dateModified = NSDate()
        
            let contentEntity = NSEntityDescription.entityForName("Content", inManagedObjectContext: managedContext)
            let content = Content(entity: contentEntity!, insertIntoManagedObjectContext: managedContext)
        
            content.body = bodyTextView.text
            note.content = content
        
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save: \(error)")
            } else {
                println("A new note saved")
                tmpNote = note
            }
        } else {
            delegate?.detailViewControllerDidNoTextEntered(self)
        }
        
        return tmpNote
    }
    
}
