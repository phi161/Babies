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

class EditBabyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var moc: NSManagedObjectContext?
    var baby: Baby?
    var visiblePickerIndexPath: NSIndexPath?
    weak var delegate: EditBabyViewControllerDelegate?
    
    enum Section: Int {
        case Dates, Adults, Gifts
    }

    let sectionHeaderTitles = [
        "Dates",
        "Adults",
        "Gifts",
        /*
         "Events",
         */
    ]

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
        
        // Populate GUI for this baby
        self.familyNameTextField.text = self.baby?.familyName
        self.givenNameTextField.text = self.baby?.givenName
    }

    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sectionHeaderTitles.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == Section.Dates.rawValue {
            return 2
        } else if section == Section.Adults.rawValue {
            if let adultsCount = self.baby?.adults?.count {
                return adultsCount+1
            } else {
                return 1
            }
        } else if section == Section.Gifts.rawValue {
            if let giftsCount = self.baby?.gifts?.count {
                return giftsCount+1
            } else {
                return 1
            }
        }
        
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionHeaderTitles[section]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var identifer: String = "AddItemCellIdentifier"
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(identifer)!
        
        if indexPath.section == Section.Dates.rawValue {
            identifer = "DatePickerCellIdentifier"
            cell = tableView.dequeueReusableCellWithIdentifier(identifer)!
        } else if indexPath.section == Section.Adults.rawValue {
            if let adultsCount = self.baby?.adults?.count {
                if indexPath.row < adultsCount {
                    identifer = "AdultCellIdentifier"
                    cell = tableView.dequeueReusableCellWithIdentifier(identifer)!
                    cell.textLabel?.text = "\(self.baby?.adults?.allObjects[indexPath.row].givenName), \(self.baby?.adults?.allObjects[indexPath.row].familyName)"
                } else {
                    identifer = "AddItemCellIdentifier"
                    cell = tableView.dequeueReusableCellWithIdentifier(identifer)!
                    cell.textLabel?.text = "Add adult"
                }
            } else {
                identifer = "AddItemCellIdentifier"
                cell = tableView.dequeueReusableCellWithIdentifier(identifer)!
                cell.textLabel?.text = "Add adult"
                
            }
        } else if indexPath.section == Section.Gifts.rawValue {
            if let giftsCount = self.baby?.gifts?.count {
                if indexPath.row < giftsCount {
                    identifer = "GiftCellIdentifier"
                    cell = tableView.dequeueReusableCellWithIdentifier(identifer)!
                    
                } else {
                    identifer = "AddItemCellIdentifier"
                    cell = tableView.dequeueReusableCellWithIdentifier(identifer)!
                    cell.textLabel?.text = "Add gift"
                }
            } else {
                identifer = "AddItemCellIdentifier"
                cell = tableView.dequeueReusableCellWithIdentifier(identifer)!
                cell.textLabel?.text = "Add gift"
            }
        }

        return cell
    }

    
    // MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == Section.Dates.rawValue {
            return 260
        } else if indexPath.section == Section.Adults.rawValue {
            if let adultsCount = self.baby?.adults?.count {
                if indexPath.row < adultsCount {
                    return 80
                } else {
                    return 50
                }
            } else {
                return 50
            }
        } else if indexPath.section == Section.Gifts.rawValue {
            if let giftsCount = self.baby?.gifts?.count {
                if indexPath.row < giftsCount {
                    return 120
                } else {
                    return 50
                }
            } else {
                return 50
            }
        }
        
        return 300
    }

/*
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            if tableView.cellForRowAtIndexPath(indexPath) is DatePickerCell {
                if visiblePickerIndexPath == indexPath {
                    visiblePickerIndexPath = nil
                } else {
                    visiblePickerIndexPath = indexPath
                }
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
        } else if indexPath.section == 1 {
            if indexPath.row == self.dataSource.numberOfItems(forSection: 1)-1 {
                UIAlertView(title: "add", message: "this will open contacts", delegate: nil, cancelButtonTitle: "sure").show()
            }
        }
        
    }
*/
    
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
        
        let newParent: Adult = NSEntityDescription.insertNewObjectForEntityForName("Adult", inManagedObjectContext: self.moc!) as! Adult
        newParent.givenName = "dad"
        newParent.familyName = "mum"
        
        let newParent1: Adult = NSEntityDescription.insertNewObjectForEntityForName("Adult", inManagedObjectContext: self.moc!) as! Adult
        newParent.givenName = "dad1"
        newParent.familyName = "mum1"
        
        let newBaby: Baby = NSEntityDescription.insertNewObjectForEntityForName("Baby", inManagedObjectContext: self.moc!) as! Baby
        newBaby.birthday = NSDate()
        newBaby.givenName = self.givenNameTextField.text
        newBaby.familyName = self.familyNameTextField.text
        newBaby.sex = self.sexSegmentedControl.selectedSegmentIndex

        newBaby.addAdultsObject(newParent)
        newParent.addBabiesObject(newBaby)
        
        newBaby.addAdultsObject(newParent1)
        newParent1.addBabiesObject(newBaby)
        
        do {
            try moc?.save()
            print("Saved \(newBaby.stringRepresentation())")
        } catch {
            print("Error: \(error)")
        }
        
        self.delegate?.editBabyViewController(self, didAddBaby: newBaby)
    }
}
