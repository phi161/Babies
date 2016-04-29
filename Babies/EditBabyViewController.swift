//
//  EditBabyViewController.swift
//  Babies
//
//  Created by phi161 on 19/04/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit
import CoreData

protocol EditBabyViewControllerDelegate: class {
    func editBabyViewController(editBabyViewController: EditBabyViewController, didAddBaby baby: Baby?)
}

class EditBabyViewController: UIViewController, UITableViewDelegate {
    
    var moc: NSManagedObjectContext?
    var baby: Baby?
    var dataSource = EditBabyDataSource()
    var visiblePickerIndexPath: NSIndexPath?
    weak var delegate: EditBabyViewControllerDelegate?

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
        
        self.tableView.dataSource = dataSource
        
        // Thumbnail Image
        self.thumbnailImageView.userInteractionEnabled = true
        self.thumbnailImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(thumbnailTapped(_:))))
    }

    
    // MARK: - UITableView

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath == visiblePickerIndexPath {
            return 260
        }
        
        return 44
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView.cellForRowAtIndexPath(indexPath) is DatePickerCell {
            if visiblePickerIndexPath == indexPath {
                visiblePickerIndexPath = nil
            } else {
                visiblePickerIndexPath = indexPath
            }
        }

        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    // MARK: - Actions

    @IBAction func sexChanged(sender: AnyObject) {
        print(#function)
    }
    
    
    func thumbnailTapped(tap:UITapGestureRecognizer) {
        print(#function)
    }
    
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.delegate?.editBabyViewController(self, didAddBaby: nil)
    }
    
    
    @IBAction func saveButtonTapped(sender: AnyObject) {

        let newBaby: Baby = NSEntityDescription.insertNewObjectForEntityForName("Baby", inManagedObjectContext: self.moc!) as! Baby
        newBaby.birthday = NSDate()
        newBaby.givenName = self.givenNameTextField.text
        newBaby.familyName = self.familyNameTextField.text
        newBaby.sex = self.sexSegmentedControl.selectedSegmentIndex
        
        do {
            try moc?.save()
            print("Saved \(newBaby.stringRepresentation())")
        } catch {
            print("Error: \(error)")
        }
        
        self.delegate?.editBabyViewController(self, didAddBaby: newBaby)
    }
}
