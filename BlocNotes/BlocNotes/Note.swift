//
//  Note.swift
//  BlocNotes
//
//  Created by Yong Jun on 6/30/15.
//  Copyright (c) 2015 Yong Jun. All rights reserved.
//

import Foundation
import CoreData

class Note: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var dateCreated: NSDate
    @NSManaged var dateModified: NSDate
    @NSManaged var content: Content

}
