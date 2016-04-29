//
//  AppDelegate.swift
//  Babies
//
//  Created by phi161 on 07/04/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // MARK: - App Delegate
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        let storeURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Babies.sqlite")
        let modelURL = NSBundle.mainBundle().URLForResource("Babies", withExtension: "momd")!
        let coreDataStack = CoreDataStack(storeURL: storeURL, modelURL: modelURL)

        let navigationController = self.window!.rootViewController as? UINavigationController
        let viewController = navigationController?.viewControllers[0] as? BabiesViewController
        viewController?.moc = coreDataStack.managedObjectContext
        
        return true
    }
    
    // MARK: - Helpers
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
}
