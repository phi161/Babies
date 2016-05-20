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
    
    var adultTypes: [AdultType]? {
        get {
            do {
                let fetchRequest = NSFetchRequest(entityName: "AdultType")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "identifier", ascending: true)]
                var result: [AdultType]?
                result = try self.managedObjectContext?.executeFetchRequest(fetchRequest) as? [AdultType]
                return result
            } catch {
                let fetchError = error as NSError
                print(fetchError)
                return nil
            }
        }
    }

    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(cancelButtonTapped(_:)))
        
        if adultTypes?.count == 0 {
            self.importFromJSON()
            tableView.reloadData()
        }
        
    }
    
    func importFromJSON() {
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

            } catch {
                print(error)
            }
        }
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = adultTypes?.count {
            return count
        } else {
            return 0
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("AdultTypeCellIdentifier", forIndexPath: indexPath)
        
        if let currentAdultType = adultTypes?[indexPath.row] {
            if let title: String = currentAdultType.title, identifier: NSNumber = currentAdultType.identifier {
                cell.textLabel?.text = "\(title) - \(identifier) - \(identifier.integerValue)"
            }
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.adultTypePickerDidCancel(self)
    }
    
    // MARK: Actions
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        delegate?.adultTypePickerDidCancel(self)
    }


}
