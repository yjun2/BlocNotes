//
//  Content.swift
//  BlocNotes
//
//  Created by Yong Jun on 6/30/15.
//  Copyright (c) 2015 Yong Jun. All rights reserved.
//

import Foundation
import CoreData

class Content: NSManagedObject {

    @NSManaged var body: String
    @NSManaged var note: Note

}
