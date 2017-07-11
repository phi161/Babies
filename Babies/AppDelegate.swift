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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let storeURL = self.applicationDocumentsDirectory.appendingPathComponent("Babies.sqlite")
        let modelURL = Bundle.main.url(forResource: "Babies", withExtension: "momd")!
        let coreDataStack = CoreDataStack(storeURL: storeURL, modelURL: modelURL)

        if let navigationController = self.window?.rootViewController as? UINavigationController,
           let viewController = navigationController.viewControllers.first as? BabiesViewController {
                viewController.moc = coreDataStack.managedObjectContext
        }

        return true
    }

    // MARK: - Helpers

    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

}
