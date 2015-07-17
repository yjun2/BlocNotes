//
//  AppDelegate.swift
//  BlocNotes
//
//  Created by Yong Jun on 6/29/15.
//  Copyright (c) 2015 Yong Jun. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let navigationController = self.window!.rootViewController as! UINavigationController
        let viewController = navigationController.topViewController as! MainNotesListTableViewController
        viewController.managedContext = coreDataStack.getCoreDataContext()
        
        return true
    }

    func applicationDidEnterBackground(application: UIApplication) {
        coreDataStack.saveContext()
    }

    func applicationWillTerminate(application: UIApplication) {
        coreDataStack.saveContext()
    }

}

