//
//  EditBabyViewController.swift
//  Babies
//
//  Created by phi161 on 19/04/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit
import CoreData

class EditBabyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let sectionHeaderTitles = [
        "Dates",
        "Parents",
        "Gifts",
        "Events",
    ]
    
    var moc: NSManagedObjectContext?
    var baby: Baby?

    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var familyNameTextField: UITextField!
    @IBOutlet var givenNameTextField: UITextField!
    @IBOutlet var sexSegmentedControl: UISegmentedControl!
    @IBOutlet var tableView: UITableView!

    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.redColor()
        
        self.title = NSLocalizedString("NEW_BABY_TITLE", comment: "The title of the new baby view controller")
        
        // Thumbnail Image
        self.thumbnailImageView.userInteractionEnabled = true
        self.thumbnailImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(thumbnailTapped(_:))))
    }

    
    // MARK: - UITableView
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sectionHeaderTitles.count
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionHeaderTitles[section]
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 44
        }
        
        return 240
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var identifer: String = "DatePickerCell"
        if indexPath.row == 0 {
            identifer = "DateCell"
        }

        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(identifer)!
        
//        cell.textLabel?.text = ("[\(indexPath.section) - \(indexPath.row)]")
        
        return cell
    }
    
    
    // MARK: - Actions

    @IBAction func sexChanged(sender: AnyObject) {
        print(#function)
    }
    
    
    func thumbnailTapped(tap:UITapGestureRecognizer) {
        print(#function)
    }
    
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let newBaby: Baby = NSEntityDescription.insertNewObjectForEntityForName("Baby", inManagedObjectContext: self.moc!) as! Baby
        newBaby.birthday = NSDate()
        newBaby.givenName = "Given"
        newBaby.familyName = self.familyNameTextField.text
        
        do {
            try moc?.save()
            print("Saved \(newBaby.stringRepresentation())")
        } catch {
            print("Error: \(error)")
        }
    }
}
