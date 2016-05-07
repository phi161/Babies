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
    func editBabyViewController(editBabyViewController: EditBabyViewController, didFinishWithBaby baby: Baby?)
}

class EditBabyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DatePickerCellDelegate {
    
    var isAddingNewEntity: Bool = false
    var moc: NSManagedObjectContext?
    var addNewBabyManagedObjectContext: NSManagedObjectContext?
    var baby: Baby?
    var visiblePickerIndexPath: NSIndexPath?
    weak var delegate: EditBabyViewControllerDelegate?
    
    enum Section: Int {
        case Dates, Adults, Gifts
    }
    
    enum DateRow: Int {
        case Delivery, Birthday
    }
    
    enum CellType: Int {
        case Unknown, Date, Adult, Gift, AddItem
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

        self.tableView.editing = true
        self.tableView.allowsSelectionDuringEditing = true
        
        self.populateWithBabyProperties()
    }
    
    func populateWithBabyProperties() {
        if isAddingNewEntity {
            // Create a new baby, empty interface
            addNewBabyManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            addNewBabyManagedObjectContext?.parentContext = self.moc
            
            let newBaby: Baby = NSEntityDescription.insertNewObjectForEntityForName("Baby", inManagedObjectContext: addNewBabyManagedObjectContext!) as! Baby
            newBaby.sex = 0
            
            self.baby = newBaby
        } else {
            // Populate GUI for this baby
            self.familyNameTextField.text = self.baby!.familyName
            self.givenNameTextField.text = self.baby!.givenName
            
            if let sex:Int = self.baby!.sex?.integerValue {
                self.sexSegmentedControl.selectedSegmentIndex = sex
            } else {
                self.sexSegmentedControl.selectedSegmentIndex = 0
            }
        }
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
        
        var identifer: String
        var cell: UITableViewCell
        
        switch cellType(forIndexPath: indexPath) {
            
        case CellType.Date:
            identifer = "DatePickerCellIdentifier"
            if let dateCell: DatePickerCell = tableView.dequeueReusableCellWithIdentifier(identifer) as? DatePickerCell {
                dateCell.delegate = self
                if indexPath.row == DateRow.Delivery.rawValue {
                    dateCell.configure(withTitle: NSLocalizedString("DELIVERY_DATE", comment: "The title of the delivery date cell"), date: self.baby?.delivery)
                } else {
                    dateCell.configure(withTitle: NSLocalizedString("BIRTHDAY_DATE", comment: "The title of the birthday date cell"), date: self.baby?.birthday)
                }
                return dateCell
            } else {
                identifer = ""
                cell = tableView.dequeueReusableCellWithIdentifier(identifer)!
            }
            
        case CellType.Adult:
            identifer = "AdultCellIdentifier"
            cell = tableView.dequeueReusableCellWithIdentifier(identifer)!
            cell.textLabel?.text = "\(self.baby?.adults?.allObjects[indexPath.row].givenName), \(self.baby?.adults?.allObjects[indexPath.row].familyName)"
        case CellType.Gift:
            identifer = "GiftCellIdentifier"
            cell = tableView.dequeueReusableCellWithIdentifier(identifer)!
        case CellType.AddItem:
            identifer = "AddItemCellIdentifier"
            cell = tableView.dequeueReusableCellWithIdentifier(identifer)!
            if indexPath.section == Section.Adults.rawValue {
                cell.textLabel?.text = "Add Adult"
            } else {
                cell.textLabel?.text = "Add Gift"
            }
        default:
            identifer = ""
            cell = tableView.dequeueReusableCellWithIdentifier(identifer)!
        }
        
        return cell
    }
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch cellType(forIndexPath: indexPath) {
        case CellType.Date:
            if indexPath == self.visiblePickerIndexPath {
                return 260
            } else {
                return 44
            }
        case CellType.Adult:
            return 80
        case CellType.Gift:
            return 120
        case CellType.AddItem:
            return 50
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        switch cellType(forIndexPath: indexPath) {
        case CellType.Date:
            let dateCell: DatePickerCell = tableView.cellForRowAtIndexPath(indexPath) as! DatePickerCell
            if visiblePickerIndexPath == indexPath {
                visiblePickerIndexPath = nil
                dateCell.setExpanded(false, animated: true)
            } else {
                // Collapse the other cell
                if  visiblePickerIndexPath != nil {
                    let expandedCell: DatePickerCell = tableView.cellForRowAtIndexPath(visiblePickerIndexPath!) as! DatePickerCell
                    expandedCell.setExpanded(false, animated: true)
                }
                visiblePickerIndexPath = indexPath
                dateCell.setExpanded(true, animated: true)
            }
            tableView.beginUpdates()
            tableView.endUpdates()
        case CellType.Adult: break
            //
        case CellType.Gift: break
            //
        case CellType.AddItem: break
            //
        default: break
            //
        }

    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        switch cellType(forIndexPath: indexPath) {
        case CellType.AddItem:
            return true
        default:
            return false
        }
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        switch cellType(forIndexPath: indexPath) {
        case CellType.AddItem:
            return .Insert
        default:
            return .None
        }
    }
    
    // MARK: - UIScrollViewDelegate

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if visiblePickerIndexPath != nil {
            let dateCell: DatePickerCell = tableView.cellForRowAtIndexPath(self.visiblePickerIndexPath!) as! DatePickerCell
            dateCell.setExpanded(false, animated: true)
            visiblePickerIndexPath = nil
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }

    // MARK: - Helpers
    
    func cellType(forIndexPath indexPath: NSIndexPath) -> CellType {
        if indexPath.section == Section.Dates.rawValue {
            return CellType.Date
        } else if indexPath.section == Section.Adults.rawValue {
            if let adultsCount = self.baby?.adults?.count {
                if indexPath.row < adultsCount {
                    return CellType.Adult
                } else {
                    return CellType.AddItem
                }
            } else {
                return CellType.AddItem
            }
        } else if indexPath.section == Section.Gifts.rawValue {
            if let giftsCount = self.baby?.gifts?.count {
                if indexPath.row < giftsCount {
                    return CellType.Gift
                } else {
                    return CellType.AddItem
                }
            } else {
                return CellType.AddItem
            }
        }
        
        return CellType.Unknown
        
    }
    
    // MARK: - Actions
    
    @IBAction func sexChanged(sender: AnyObject) {
        print(#function)
    }
    
    
    func thumbnailTapped(tap:UITapGestureRecognizer) {
        print(#function)
    }
    
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.delegate?.editBabyViewController(self, didFinishWithBaby: nil)
    }
    
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        
        self.baby?.givenName = self.givenNameTextField.text
        self.baby?.familyName = self.familyNameTextField.text
        self.baby?.sex = self.sexSegmentedControl.selectedSegmentIndex

        if isAddingNewEntity {
            addNewBabyManagedObjectContext?.performBlock({
                do {
                    try self.addNewBabyManagedObjectContext?.save()
                    print("Saved child context!")
                    self.moc?.performBlock({
                        do {
                            try self.moc?.save()
                            print("Saved main context!")
                        } catch {
                            print("Error for main: \(error)")
                        }
                    })
                } catch {
                    print("Error for child: \(error)")
                }
            })
        } else {
            do {
                try moc?.save()
                print("Saved!")
            } catch {
                print("Error: \(error)")
            }
        }
        
        /*
        let newParent: Adult = NSEntityDescription.insertNewObjectForEntityForName("Adult", inManagedObjectContext: self.moc!) as! Adult
        newParent.givenName = "dad"
        newParent.familyName = "mum"
        
        let newParent1: Adult = NSEntityDescription.insertNewObjectForEntityForName("Adult", inManagedObjectContext: self.moc!) as! Adult
        newParent1.givenName = "dad1"
        newParent1.familyName = "mum1"
        
        let newBaby: Baby = NSEntityDescription.insertNewObjectForEntityForName("Baby", inManagedObjectContext: self.moc!) as! Baby
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
        */
        
        self.delegate?.editBabyViewController(self, didFinishWithBaby: self.baby)
    }
    
    // MARK: - DatePickerCellDelegate
    
    func datePickerCell(datePickerCell: DatePickerCell, didSelectDate date: NSDate) {
        if self.visiblePickerIndexPath?.row == DateRow.Delivery.rawValue {
            self.baby?.delivery = date
        } else if self.visiblePickerIndexPath?.row == DateRow.Birthday.rawValue {
            self.baby?.birthday = date
        }
    }
    
    func datePickerCellDidClear(datePickerCell: DatePickerCell) {
        
        if self.visiblePickerIndexPath?.row == DateRow.Delivery.rawValue {
            self.baby?.delivery = nil
        } else if self.visiblePickerIndexPath?.row == DateRow.Birthday.rawValue {
            self.baby?.birthday = nil
        }
        
        if visiblePickerIndexPath != nil {
            datePickerCell.setExpanded(false, animated: true)
            visiblePickerIndexPath = nil
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
}
