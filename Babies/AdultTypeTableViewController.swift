//
//  AdultTypeTableViewController.swift
//  Babies
//
//  Created by phi161 on 17/05/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit
import CoreData

protocol AdultTypePickerDelegate: class {
    func adultTypePicker(adultTypePicker: AdultTypeTableViewController, didSelectType type:AdultType)
    func adultTypePickerDidCancel(adultTypePicker: AdultTypeTableViewController)
}

class AdultTypeTableViewController: UITableViewController {
    
    var adultType: AdultType?
    weak var delegate: AdultTypePickerDelegate?
    var managedObjectContext: NSManagedObjectContext?
    var dataSource: [AdultType]?

    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = NSFetchRequest(entityName: "AdultType")
        
        var result: [AdultType]?
        do {
            result = try self.managedObjectContext?.executeFetchRequest(fetchRequest) as? [AdultType]
            dataSource = result
            print(result)
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        if result?.count == 0 {
            // Populate from JSON
            let jsonFileURL = NSBundle.mainBundle().URLForResource("adult_types", withExtension: "json")
            
            if let jsonData = NSData(contentsOfURL: jsonFileURL!) {
                do {
                    let jsonArray: Array! = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers) as? Array<[String:AnyObject]>
                    for item in jsonArray {
                        
                        guard let title = item["title"] as? String, identifier = item["identifier"] as? Int else {
                            return;
                        }
                        
                        let adultType = AdultType(title: title, identifier: identifier, userDefined: false, context: managedObjectContext!)
                        managedObjectContext?.insertObject(adultType)
                        
                    }
                    
                    do {
                        try managedObjectContext!.save()
                        print("Saved main context!")
                    } catch {
                        print("Error for main: \(error)")
                    }
                    
                    // TODO: Set dataSource and reloadData()

                    
                } catch {
                    print(error)
                }
            }
        }
        
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dataSource?.count)!
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("AdultTypeCellIdentifier", forIndexPath: indexPath)
        
        if dataSource != nil {
            let currentAdultType = dataSource![indexPath.row]
            if let title = currentAdultType.title as String!, identifier = currentAdultType.identifier as Int! {
                cell.textLabel?.text = "\(title) - \(identifier)"
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.adultTypePickerDidCancel(self)
    }

}
