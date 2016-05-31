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
import Photos

protocol EditBabyViewControllerDelegate: class {
    func editBabyViewController(editBabyViewController: EditBabyViewController, didFinishWithBaby baby: Baby?)
}

class EditBabyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DatePickerCellDelegate, AdultCellDelegate, CNContactPickerDelegate, AdultTypePickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GiftViewControllerDelegate {
    
    var isAddingNewEntity: Bool = false
    var moc: NSManagedObjectContext?
    var babyObjectId: NSManagedObjectID?
    weak var delegate: EditBabyViewControllerDelegate?
    
    private var temporaryMoc: NSManagedObjectContext?
    private var baby: Baby?
    private var visiblePickerIndexPath: NSIndexPath?
    private var selectedIndexPath: NSIndexPath?
    private var shouldDeleteImage = false // Used to delete/restore images during save/cancel
    
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
            newBaby.imageName = NSUUID().UUIDString
            
            self.baby = newBaby
        } else {
            self.baby = temporaryMoc?.objectWithID(self.babyObjectId!) as? Baby
        }
        
        // Populate GUI for this baby
        self.familyNameTextField.text = self.baby!.familyName
        self.givenNameTextField.text = self.baby!.givenName
        
        self.thumbnailImageView.image = self.baby?.thumbnailImage
        
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
        // TODO: Take care of adultType as well
        
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
        if let adultTypePicker: AdultTypeTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AdultTypeViewControllerIdentifier") as? AdultTypeTableViewController {
            let navigationController = UINavigationController(rootViewController: adultTypePicker)
            adultTypePicker.delegate = self
            adultTypePicker.managedObjectContext = self.moc
            self.presentViewController(navigationController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Gifts Section
    
    func insertGift() {
        let newGift: Gift = NSEntityDescription.insertNewObjectForEntityForName("Gift", inManagedObjectContext: self.temporaryMoc!) as! Gift
        newGift.date = NSDate()
        newGift.price = 0
        newGift.baby = self.baby
        newGift.details = "tap to edit details"
        self.baby?.addGiftsObject(newGift)

        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: (self.baby?.gifts?.count)!-1, inSection: Section.Gifts.rawValue)], withRowAnimation: .Fade)
        self.tableView.endUpdates()
    }

    func giftViewController(giftViewController: GiftViewController, didFinishWithGift gift: Gift) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        self.tableView.reloadSections(NSIndexSet(index: Section.Gifts.rawValue), withRowAnimation: .Automatic)
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
                    // Type
                    adultCell.typeButton.setTitle(adult.type?.title ?? "type", forState: .Normal)
                    // Name
                    if adult.contactIdentifier != nil {
                        adultCell.contactButton.setTitle(adult.name(), forState: .Normal)
                    } else {
                        adultCell.contactButton.setTitle("select contact", forState: .Normal)
                    }
                } else {
                    adultCell.contactButton.setTitle("problem", forState: .Normal)
                }
            }
            
        case CellType.Gift:
            if let giftCell: GiftCell = cell as? GiftCell {
                if let gift = self.baby?.giftsOrdered()![indexPath.row] {
                    giftCell.updateInterface(gift)
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
            return 80
        case CellType.AddItem:
            return 50
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        switch cellType(forIndexPath: indexPath) {
        case CellType.Date:
            self.view.endEditing(true)

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
        case CellType.Gift:
            if let gift = self.baby?.giftsOrdered()![indexPath.row] {
                let giftViewController = GiftViewController(gift: gift)
                giftViewController.delegate = self
                let navigationController = UINavigationController(rootViewController: giftViewController)
                self.presentViewController(navigationController, animated: true, completion: nil)
            }
        case CellType.AddItem:
            if indexPath.section == Section.Adults.rawValue {
                self.insertAdult()
            } else if indexPath.section == Section.Gifts.rawValue {
                self.insertGift()
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
    
    func canAccessCamera() -> Bool {
        let mediaType = AVMediaTypeVideo
        let status = AVCaptureDevice.authorizationStatusForMediaType(mediaType)
        
        if (status == .Denied || status == .Restricted) {
            return false
        }
        
        return true
    }

    func canAccessPhotos() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        
        if (status == .Denied || status == .Restricted) {
            return false
        }
        
        return true
    }

    // MARK: - Actions
    
    @IBAction func sexChanged(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    
    func thumbnailTapped(tap:UITapGestureRecognizer) {
        self.view.endEditing(true)
        
        let alertController = UIAlertController(
            title: NSLocalizedString("PHOTO_TITLE", comment: "The title of the alert message when tapping the image thumbnail"),
            message: NSLocalizedString("PHOTO_MESSAGE", comment: "The message of the alert message when tapping the image thumbnail"), preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("PHOTO_CANCEL", comment: "The title of the cancel option when tapping the image thumbnail"), style: .Cancel) { (action) in
            //
        }
        
        let takePhotoAction = UIAlertAction(title: NSLocalizedString("PHOTO_TAKE", comment: "The title of the camera option when tapping the image thumbnail"), style: .Default) { (action) in
            if self.canAccessCamera() {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .Camera
                imagePicker.allowsEditing = true
                self.presentViewController(imagePicker, animated: true, completion: nil)
            } else {
                print("no camera access")
            }
        }
        
        let choosePhotoAction = UIAlertAction(title: NSLocalizedString("PHOTO_CHOOSE", comment: "The title of the library option when tapping the image thumbnail"), style: .Default) { (action) in
            if self.canAccessPhotos() {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .PhotoLibrary
                imagePicker.allowsEditing = true
                self.presentViewController(imagePicker, animated: true, completion: nil)
            } else {
                print("no photos access")
            }
        }
        
        let deletePhotoAction = UIAlertAction(title: NSLocalizedString("PHOTO_DELETE", comment: "The title of the delete option when tapping the image thumbnail"), style: .Default) { (action) in
            
            let deleteController = UIAlertController(
                title: NSLocalizedString("DELETE_PHOTO_TITLE", comment: "The title of the alert for deleting a photo"),
                message: NSLocalizedString("DELETE_PHOTO_MESSAGE", comment: "The message of the alert for deleting a photo"),
                preferredStyle: .ActionSheet)
            
            let deleteAction = UIAlertAction(title: NSLocalizedString("PHOTO_DELETE", comment: "The title of the delete option when tapping the image thumbnail"), style: .Destructive, handler: { (action) in
                self.shouldDeleteImage = true

                // TODO: Use default image instead
                self.thumbnailImageView.image = nil
            })
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("PHOTO_CANCEL", comment: "The title of the cancel option when tapping the image thumbnail"), style: .Cancel, handler: { (action) in
                //
            })
            deleteController.addAction(deleteAction)
            deleteController.addAction(cancelAction)
            
            self.presentViewController(deleteController, animated: true, completion: nil)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            alertController.addAction(takePhotoAction)
        }
        
        alertController.addAction(choosePhotoAction)
        
        if self.baby?.thumbnailImage != nil || !self.shouldDeleteImage {
            alertController.addAction(deletePhotoAction)
        }
        
        alertController.addAction(cancelAction)

        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.delegate?.editBabyViewController(self, didFinishWithBaby: nil)
        
        // Delete temp image if any
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let tempUrl = urls[urls.count-1].URLByAppendingPathComponent("temp.jpg")
        do {
            try NSFileManager.defaultManager().removeItemAtURL(tempUrl)
        } catch {
            print(error)
        }
    }
    
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        
        self.baby?.givenName = self.givenNameTextField.text
        self.baby?.familyName = self.familyNameTextField.text
        self.baby?.sex = self.sexSegmentedControl.selectedSegmentIndex
        
        if self.shouldDeleteImage { // Delete both temp & original images
            let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            let url = urls[urls.count-1].URLByAppendingPathComponent((self.baby?.imageName)!)
            let tempUrl = urls[urls.count-1].URLByAppendingPathComponent("temp.jpg")

            do {
                try NSFileManager.defaultManager().removeItemAtURL(url)
                try NSFileManager.defaultManager().removeItemAtURL(tempUrl)
            } catch {
                print(error)
            }
        } else { // If there is a temp image, delete "baby.imageName" and rename temp to "baby.imageName"
            let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            let tempUrl = urls[urls.count-1].URLByAppendingPathComponent("temp.jpg")

            guard let path = tempUrl.path else {return }
            if NSFileManager.defaultManager().fileExistsAtPath(path) {
                let url = urls[urls.count-1].URLByAppendingPathComponent((self.baby?.imageName)!)
                do {
                    try NSFileManager.defaultManager().removeItemAtURL(url)
                } catch {
                    print("could not remove \(url.path)")
                }
                
                do {
                    try NSFileManager.defaultManager().moveItemAtURL(tempUrl, toURL: url)
                } catch {
                    print(error)
                }
            }
        }
        
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
        selectedIndexPath = tableView.indexPathForCell(adultCell)
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
        //
    }
    
    // MARK: - AdultTypePickerDelegate
    
    func adultTypePickerDidCancel(adultTypePicker: AdultTypeTableViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func adultTypePicker(adultTypePicker: AdultTypeTableViewController, didSelectType type: AdultType) {
        self.dismissViewControllerAnimated(true, completion: nil)

        if let adult: Adult = self.baby?.adultsOrdered()![selectedIndexPath!.row] {
            // TODO: Investigate if inverse relationship should also be set
            let adultType = self.temporaryMoc?.objectWithID(type.objectID) as! AdultType
            adult.type = adultType
            self.tableView.reloadSections(NSIndexSet(index: Section.Adults.rawValue), withRowAnimation: .Automatic)
        } else {
            //
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            self.shouldDeleteImage = false

            let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            let url = urls[urls.count-1].URLByAppendingPathComponent("temp.jpg")
            UIImageJPEGRepresentation(image, 1)?.writeToURL(url, atomically: true)
            

            self.thumbnailImageView.alpha = 0
            self.thumbnailImageView.image = image
            self.dismissViewControllerAnimated(true, completion: { 
                UIView.animateWithDuration(0.3, animations: { 
                    self.thumbnailImageView.alpha = 1
                })
            })
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
