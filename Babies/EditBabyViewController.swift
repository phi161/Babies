//
//  EditBabyViewController.swift
//  Babies
//
//  Created by phi161 on 19/04/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit
import CoreData
import ContactsUI

protocol EditBabyViewControllerDelegate: class {
    func editBabyViewController(editBabyViewController: EditBabyViewController, didFinishWithBaby baby: Baby?)
}

class EditBabyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DatePickerCellDelegate, AdultCellDelegate, CNContactPickerDelegate {
    
    var isAddingNewEntity: Bool = false
    var moc: NSManagedObjectContext?
    var babyObjectId: NSManagedObjectID?
    weak var delegate: EditBabyViewControllerDelegate?
    
    private var temporaryMoc: NSManagedObjectContext?
    private var baby: Baby?
    private var visiblePickerIndexPath: NSIndexPath?
    private var selectedIndexPath: NSIndexPath?
    
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
        temporaryMoc = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        temporaryMoc?.parentContext = self.moc
        
        if isAddingNewEntity {
            // Create a new baby, empty interface
            let newBaby: Baby = NSEntityDescription.insertNewObjectForEntityForName("Baby", inManagedObjectContext: temporaryMoc!) as! Baby
            newBaby.sex = 0
            
            self.baby = newBaby
        } else {
            self.baby = temporaryMoc?.objectWithID(self.babyObjectId!) as? Baby
        }
        
        // Populate GUI for this baby
        self.familyNameTextField.text = self.baby!.familyName
        self.givenNameTextField.text = self.baby!.givenName
        
        if let sex:Int = self.baby!.sex?.integerValue {
            self.sexSegmentedControl.selectedSegmentIndex = sex
        } else {
            self.sexSegmentedControl.selectedSegmentIndex = 0
        }

    }
    
    // MARK: - Adults Section
    
    func insertAdult() {
        let newAdult: Adult = NSEntityDescription.insertNewObjectForEntityForName("Adult", inManagedObjectContext: self.temporaryMoc!) as! Adult
        newAdult.displayOrder = self.baby?.adults?.count
        newAdult.addBabiesObject(self.baby!)
        self.baby?.addAdultsObject(newAdult)
        
        
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: (self.baby?.adults?.count)!-1, inSection: Section.Adults.rawValue)], withRowAnimation: .Fade)
        self.tableView.endUpdates()
    }
    
    func removeAdult(atIndexPath indexPath: NSIndexPath) {
        if let adult: Adult = self.baby?.adultsOrdered()![indexPath.row] {
            self.baby?.removeAdultsObject(adult)
            adult.removeBabiesObject(self.baby!)
            self.temporaryMoc?.deleteObject(adult)
        } else {
            print("Attempt to delete the wrong Adult entity")
        }
        
        self.tableView.beginUpdates()
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        self.tableView.endUpdates()
    }
    
    func pickAdultType() {
        let adultTypePicker = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AdultTypeViewControllerIdentifier")
        let navigationController = UINavigationController(rootViewController: adultTypePicker)
        
        self.presentViewController(navigationController, animated: true, completion: nil)
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
                    dateCell.configure(withTitle: NSLocalizedString("DELIVERY_DATE", comment: "The title of the delivery date cell"), date: self.baby?.delivery, mode: .Date)
                } else {
                    dateCell.configure(withTitle: NSLocalizedString("BIRTHDAY_DATE", comment: "The title of the birthday date cell"), date: self.baby?.birthday, mode: .DateAndTime)
                }
                return dateCell
            } else {
                identifer = ""
                cell = tableView.dequeueReusableCellWithIdentifier(identifer)!
            }
            
        case CellType.Adult:
            identifer = "AdultCellIdentifier"
            if let adultCell: AdultCell = tableView.dequeueReusableCellWithIdentifier(identifer) as? AdultCell {
                adultCell.delegate = self
                return adultCell
            } else {
                identifer = ""
                cell = tableView.dequeueReusableCellWithIdentifier(identifer)!
            }

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
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        switch cellType(forIndexPath: indexPath) {

        case CellType.Adult:
            if let adultCell: AdultCell = cell as? AdultCell {
                if let adult = self.baby?.adultsOrdered()![indexPath.row] {
                    if adult.contactIdentifier != nil {
                        adultCell.contactButton.setTitle(adult.stringRepresentation(), forState: .Normal)
                    } else {
                        adultCell.contactButton.setTitle("choose", forState: .Normal)
                    }
                } else {
                    adultCell.contactButton.setTitle("problem", forState: .Normal)
                }
            }
            
        default: break
        }

    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        switch cellType(forIndexPath: indexPath) {
        case CellType.Adult:
            if self.baby?.adults?.count > 1 {
                return true
            } else {
                return false
            }
        default:
            return false
        }
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        // Set the displayOrder property
        var updatedOrderedAults = self.baby?.adultsOrdered()!
        var adult = updatedOrderedAults![sourceIndexPath.row]
        updatedOrderedAults?.removeAtIndex(sourceIndexPath.row)
        updatedOrderedAults?.insert(adult, atIndex: destinationIndexPath.row)
        
        
        var start = sourceIndexPath.row
        if destinationIndexPath.row < start { // moving up
            start = destinationIndexPath.row
        }
        
        var end = destinationIndexPath.row
        if sourceIndexPath.row > end { // moving down
            end = sourceIndexPath.row
        }
        
        for index in start...end {
            adult = updatedOrderedAults![index]
            adult.displayOrder = index
        }

    }
    
    
    func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        if proposedDestinationIndexPath.section != Section.Adults.rawValue {
            return sourceIndexPath
        } else {
            if proposedDestinationIndexPath.row == self.baby?.adults?.count { // if user tries to drag below the "add item" cell
                return sourceIndexPath
            } else {
                return proposedDestinationIndexPath
            }
        }
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
        case CellType.Gift: break
            //
        case CellType.AddItem:
            if indexPath.section == Section.Adults.rawValue {
                self.insertAdult()
            } else {
                //
            }
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
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            self.removeAdult(atIndexPath: indexPath)
        } else if editingStyle == .Insert {
            // Tapped the green "+" icon
        }
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        switch cellType(forIndexPath: indexPath) {
        case CellType.Adult:
            return .Delete
        case CellType.AddItem:
            return .Insert
        default:
            return .None
        }
    }
    
    // MARK: - UIScrollViewDelegate

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        self.view.endEditing(true)
        
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
                if indexPath.row == adultsCount {
                    return CellType.AddItem
                } else {
                    return CellType.Adult
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

        temporaryMoc?.performBlock({
            do {
                try self.temporaryMoc?.save()
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
    
    // MARK: - AdultCellDelegate
    
    func adultCellDidTapTypeButton(adultCell: AdultCell) {
        self.pickAdultType()
    }
    
    func adultCellDidTapContactButton(adultCell: AdultCell) {
        selectedIndexPath = tableView.indexPathForCell(adultCell)
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        self.presentViewController(contactPicker, animated: true, completion: nil)
    }
    
    // MARK: - CNContactPickerDelegate
    
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {

        self.tableView.deselectRowAtIndexPath(selectedIndexPath!, animated: true)
        
        if let adult: Adult = self.baby?.adultsOrdered()![selectedIndexPath!.row] {
            adult.familyName = contact.familyName
            adult.givenName = contact.givenName
            adult.contactIdentifier = contact.identifier
            
            self.tableView.reloadSections(NSIndexSet(index: Section.Adults.rawValue), withRowAnimation: .Automatic)
        } else {
            //
        }

    }
    
    func contactPickerDidCancel(picker: CNContactPickerViewController) {
        self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow!, animated: true)
    }
    
}
