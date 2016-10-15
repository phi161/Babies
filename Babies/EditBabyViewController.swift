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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol EditBabyViewControllerDelegate: class {
    func editBabyViewController(_ editBabyViewController: EditBabyViewController, didFinishWithBaby baby: Baby?)
}

class EditBabyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DatePickerCellDelegate, AdultCellDelegate, CNContactPickerDelegate, AdultTypePickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GiftViewControllerDelegate {
    
    var isAddingNewEntity: Bool = false
    var moc: NSManagedObjectContext?
    var babyObjectId: NSManagedObjectID?
    weak var delegate: EditBabyViewControllerDelegate?
    
    fileprivate var temporaryMoc: NSManagedObjectContext?
    fileprivate var baby: Baby?
    fileprivate var visiblePickerIndexPath: IndexPath?
    fileprivate var selectedIndexPath: IndexPath?
    fileprivate var shouldDeleteImage = false // Used to delete/restore images during save/cancel
    
    enum Section: Int {
        case dates, adults, gifts, notes
    }
    
    enum DateRow: Int {
        case delivery, birthday
    }
    
    enum CellType: Int {
        case unknown, date, adult, gift, addItem, notes
    }
    
    let sectionHeaderTitles = [
        NSLocalizedString("SECTION_TITLE_DATES", comment: "The section title for dates"),
        NSLocalizedString("SECTION_TITLE_ADULTS", comment: "The section title for adults"),
        NSLocalizedString("SECTION_TITLE_GIFTS", comment: "The section title for gifts"),
        NSLocalizedString("SECTION_TITLE_NOTES", comment: "The section title for notes")
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
        
        self.view.backgroundColor = UIColor.red
        
        self.title = NSLocalizedString("NEW_BABY_TITLE", comment: "The title of the new baby view controller")
        
        // Thumbnail Image
        self.thumbnailImageView.isUserInteractionEnabled = true
        self.thumbnailImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(thumbnailTapped(_:))))

        self.tableView.isEditing = true
        self.tableView.allowsSelectionDuringEditing = true
        self.tableView.register(UINib.init(nibName: "GiftCell", bundle: nil), forCellReuseIdentifier: "GiftCellIdentifier")
        
        self.populateWithBabyProperties()
    }
    
    func populateWithBabyProperties() {
        temporaryMoc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        temporaryMoc?.parent = self.moc
        
        if isAddingNewEntity {
            // Create a new baby, empty interface
            let newBaby: Baby = NSEntityDescription.insertNewObject(forEntityName: "Baby", into: temporaryMoc!) as! Baby
            newBaby.sex = 0
            newBaby.imageName = UUID().uuidString
            
            self.baby = newBaby
        } else {
            self.baby = temporaryMoc?.object(with: self.babyObjectId!) as? Baby
        }
        
        // Populate GUI for this baby
        self.familyNameTextField.text = self.baby!.familyName
        self.givenNameTextField.text = self.baby!.givenName
        
        self.thumbnailImageView.image = self.baby?.thumbnailImage
        
        if let sex:Int = self.baby!.sex?.intValue {
            self.sexSegmentedControl.selectedSegmentIndex = sex
        } else {
            self.sexSegmentedControl.selectedSegmentIndex = 0
        }

    }
    
    // MARK: - Adults Section
    
    func insertAdult() {
        let newAdult: Adult = NSEntityDescription.insertNewObject(forEntityName: "Adult", into: self.temporaryMoc!) as! Adult
        newAdult.displayOrder = self.baby?.adults?.count as NSNumber?
        newAdult.addBabiesObject(self.baby!)
        self.baby?.addAdultsObject(newAdult)
        
        
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath(row: (self.baby?.adults?.count)!-1, section: Section.adults.rawValue)], with: .fade)
        self.tableView.endUpdates()
    }
    
    func removeAdult(atIndexPath indexPath: IndexPath) {
        // TODO: Take care of adultType as well
        
        if let adult: Adult = self.baby?.adultsOrdered()![(indexPath as NSIndexPath).row] {
            self.baby?.removeAdultsObject(adult)
            adult.removeBabiesObject(self.baby!)
            self.temporaryMoc?.delete(adult)
        } else {
            print("Attempt to delete the wrong Adult entity")
        }
        
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        self.tableView.endUpdates()
    }
    
    func pickAdultType() {
        if let adultTypePicker: AdultTypeTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AdultTypeViewControllerIdentifier") as? AdultTypeTableViewController {
            let navigationController = UINavigationController(rootViewController: adultTypePicker)
            adultTypePicker.delegate = self
            adultTypePicker.managedObjectContext = self.moc
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Gifts Section
    
    func insertGift() {
        let newGift: Gift = NSEntityDescription.insertNewObject(forEntityName: "Gift", into: self.temporaryMoc!) as! Gift
        newGift.date = Date()
        newGift.price = 0
        newGift.baby = self.baby
        newGift.details = ""
        self.baby?.addGiftsObject(newGift)

        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath(row: (self.baby?.gifts?.count)!-1, section: Section.gifts.rawValue)], with: .fade)
        self.tableView.endUpdates()
    }
    
    func removeGift(atIndexPath indexPath: IndexPath) {
        if let gift: Gift = self.baby?.giftsOrdered()![(indexPath as NSIndexPath).row] {
            self.baby?.removeGiftsObject(gift)
            self.temporaryMoc?.delete(gift)
        } else {
            print("Attempt to delete the wrong Gift entity")
        }
        
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        self.tableView.endUpdates()
    }

    func giftViewController(_ giftViewController: GiftViewController, didFinishWithGift gift: Gift) {
        self.dismiss(animated: true, completion: nil)
        
        self.tableView.reloadSections(IndexSet(integer: Section.gifts.rawValue), with: .automatic)
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionHeaderTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == Section.dates.rawValue {
            return 2
        } else if section == Section.adults.rawValue {
            if let adultsCount = self.baby?.adults?.count {
                return adultsCount+1
            } else {
                return 1
            }
        } else if section == Section.gifts.rawValue {
            if let giftsCount = self.baby?.gifts?.count {
                return giftsCount+1
            } else {
                return 1
            }
        } else if section == Section.notes.rawValue {
            return 1
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionHeaderTitles[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var identifer: String
        var cell: UITableViewCell
        
        switch cellType(forIndexPath: indexPath) {
            
        case CellType.date:
            identifer = "DatePickerCellIdentifier"
            if let dateCell: DatePickerCell = tableView.dequeueReusableCell(withIdentifier: identifer) as? DatePickerCell {
                dateCell.delegate = self
                if (indexPath as NSIndexPath).row == DateRow.delivery.rawValue {
                    dateCell.configure(withTitle: NSLocalizedString("DELIVERY_DATE", comment: "The title of the delivery date cell"), date: self.baby?.delivery, mode: .date)
                } else {
                    dateCell.configure(withTitle: NSLocalizedString("BIRTHDAY_DATE", comment: "The title of the birthday date cell"), date: self.baby?.birthday, mode: .dateAndTime)
                }
                return dateCell
            } else {
                identifer = ""
                cell = tableView.dequeueReusableCell(withIdentifier: identifer)!
            }
            
        case CellType.adult:
            identifer = "AdultCellIdentifier"
            if let adultCell: AdultCell = tableView.dequeueReusableCell(withIdentifier: identifer) as? AdultCell {
                adultCell.delegate = self
                return adultCell
            } else {
                identifer = ""
                cell = tableView.dequeueReusableCell(withIdentifier: identifer)!
            }

        case CellType.gift:
            identifer = "GiftCellIdentifier"
            cell = tableView.dequeueReusableCell(withIdentifier: identifer)!
        case CellType.addItem:
            identifer = "AddItemCellIdentifier"
            cell = tableView.dequeueReusableCell(withIdentifier: identifer)!
            if (indexPath as NSIndexPath).section == Section.adults.rawValue {
                cell.textLabel?.text = NSLocalizedString("ADD_ADULT", comment: "Text for adding a new adult")
            } else {
                cell.textLabel?.text = NSLocalizedString("ADD_GIFT", comment: "Text for adding a new gift")
            }
        case CellType.notes:
            identifer = "EditNotesCellIdentifier"
            cell = tableView.dequeueReusableCell(withIdentifier: identifer)!
        default:
            identifer = ""
            cell = tableView.dequeueReusableCell(withIdentifier: identifer)!
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        switch cellType(forIndexPath: indexPath) {

        case CellType.adult:
            if let adultCell: AdultCell = cell as? AdultCell {
                if let adult = self.baby?.adultsOrdered()![(indexPath as NSIndexPath).row] {
                    // Type
                    adultCell.typeButton.setTitle(adult.type?.title ?? NSLocalizedString("SELECT_TYPE", comment: "Text for opening the contact type view while adding a new adult"), for: UIControlState())
                    // Name
                    if adult.contactIdentifier != nil {
                        adultCell.contactButton.setTitle(adult.name(), for: UIControlState())
                    } else {
                        adultCell.contactButton.setTitle(NSLocalizedString("SELECT_CONTACT", comment: "Text for opening the contact picker while adding a new adult"), for: UIControlState())
                    }
                } else {
                    adultCell.contactButton.setTitle("problem", for: UIControlState())
                }
            }
            
        case CellType.gift:
            if let giftCell: GiftCell = cell as? GiftCell {
                if let gift = self.baby?.giftsOrdered()![(indexPath as NSIndexPath).row] {
                    giftCell.updateInterface(gift)
                }
            }
            
        default: break
        }

    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        switch cellType(forIndexPath: indexPath) {
        case CellType.adult:
            if self.baby?.adults?.count > 1 {
                return true
            } else {
                return false
            }
        default:
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Set the displayOrder property
        var updatedOrderedAults = self.baby?.adultsOrdered()!
        var adult = updatedOrderedAults![(sourceIndexPath as NSIndexPath).row]
        updatedOrderedAults?.remove(at: (sourceIndexPath as NSIndexPath).row)
        updatedOrderedAults?.insert(adult, at: (destinationIndexPath as NSIndexPath).row)
        
        
        var start = (sourceIndexPath as NSIndexPath).row
        if (destinationIndexPath as NSIndexPath).row < start { // moving up
            start = (destinationIndexPath as NSIndexPath).row
        }
        
        var end = (destinationIndexPath as NSIndexPath).row
        if (sourceIndexPath as NSIndexPath).row > end { // moving down
            end = (sourceIndexPath as NSIndexPath).row
        }
        
        for index in start...end {
            adult = updatedOrderedAults![index]
            adult.displayOrder = index as NSNumber?
        }

    }
    
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if (proposedDestinationIndexPath as NSIndexPath).section != Section.adults.rawValue {
            return sourceIndexPath
        } else {
            if (proposedDestinationIndexPath as NSIndexPath).row == self.baby?.adults?.count { // if user tries to drag below the "add item" cell
                return sourceIndexPath
            } else {
                return proposedDestinationIndexPath
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch cellType(forIndexPath: indexPath) {
        case CellType.date:
            if indexPath == self.visiblePickerIndexPath {
                return 260
            } else {
                return 44
            }
        case CellType.adult:
            return 80
        case CellType.gift:
            return 66
        case CellType.addItem:
            return 50
        case CellType.notes:
            return 100
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch cellType(forIndexPath: indexPath) {
        case CellType.date:
            self.view.endEditing(true)

            let dateCell: DatePickerCell = tableView.cellForRow(at: indexPath) as! DatePickerCell
            if visiblePickerIndexPath == indexPath {
                visiblePickerIndexPath = nil
                dateCell.setExpanded(false, animated: true)
            } else {
                // Collapse the other cell
                if  visiblePickerIndexPath != nil {
                    let expandedCell: DatePickerCell = tableView.cellForRow(at: visiblePickerIndexPath!) as! DatePickerCell
                    expandedCell.setExpanded(false, animated: true)
                }
                visiblePickerIndexPath = indexPath
                dateCell.setExpanded(true, animated: true)
            }
            tableView.beginUpdates()
            tableView.endUpdates()
        case CellType.gift:
            if let gift = self.baby?.giftsOrdered()![(indexPath as NSIndexPath).row] {
                let giftViewController = GiftViewController(gift: gift)
                giftViewController.delegate = self
                let navigationController = UINavigationController(rootViewController: giftViewController)
                self.present(navigationController, animated: true, completion: nil)
            }
        case CellType.addItem:
            if (indexPath as NSIndexPath).section == Section.adults.rawValue {
                self.insertAdult()
            } else if (indexPath as NSIndexPath).section == Section.gifts.rawValue {
                self.insertGift()
            }
        default: break
            //
        }

    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        switch cellType(forIndexPath: indexPath) {
        case CellType.addItem:
            return true
        default:
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if (indexPath as NSIndexPath).section == Section.adults.rawValue {
                self.removeAdult(atIndexPath: indexPath)
            } else if (indexPath as NSIndexPath).section == Section.gifts.rawValue {
                self.removeGift(atIndexPath: indexPath)
            }
        } else if editingStyle == .insert {
            // Tapped the green "+" icon
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        switch cellType(forIndexPath: indexPath) {
        case CellType.adult,
             CellType.gift:
            return .delete
        case CellType.addItem:
            return .insert
        default:
            return .none
        }
    }
    
    // MARK: - UIScrollViewDelegate

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        self.view.endEditing(true)
        
        if visiblePickerIndexPath != nil {
            let dateCell: DatePickerCell = tableView.cellForRow(at: self.visiblePickerIndexPath!) as! DatePickerCell
            dateCell.setExpanded(false, animated: true)
            visiblePickerIndexPath = nil
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }

    // MARK: - Helpers
    
    func cellType(forIndexPath indexPath: IndexPath) -> CellType {
        if (indexPath as NSIndexPath).section == Section.dates.rawValue {
            return CellType.date
        } else if (indexPath as NSIndexPath).section == Section.adults.rawValue {
            if let adultsCount = self.baby?.adults?.count {
                if (indexPath as NSIndexPath).row == adultsCount {
                    return CellType.addItem
                } else {
                    return CellType.adult
                }
            } else {
                return CellType.addItem
            }
        } else if (indexPath as NSIndexPath).section == Section.gifts.rawValue {
            if let giftsCount = self.baby?.gifts?.count {
                if (indexPath as NSIndexPath).row < giftsCount {
                    return CellType.gift
                } else {
                    return CellType.addItem
                }
            } else {
                return CellType.addItem
            }
        } else if (indexPath.section == Section.notes.rawValue) {
            return CellType.notes
        }
        
        return CellType.unknown
        
    }
    
    func canAccessCamera() -> Bool {
        let mediaType = AVMediaTypeVideo
        let status = AVCaptureDevice.authorizationStatus(forMediaType: mediaType)
        
        if (status == .denied || status == .restricted) {
            return false
        }
        
        return true
    }

    func canAccessPhotos() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        
        if (status == .denied || status == .restricted) {
            return false
        }
        
        return true
    }

    // MARK: - Actions
    
    @IBAction func sexChanged(_ sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    
    func thumbnailTapped(_ tap:UITapGestureRecognizer) {
        self.view.endEditing(true)
        
        let alertController = UIAlertController(
            title: NSLocalizedString("PHOTO_TITLE", comment: "The title of the alert message when tapping the image thumbnail"),
            message: NSLocalizedString("PHOTO_MESSAGE", comment: "The message of the alert message when tapping the image thumbnail"), preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("PHOTO_CANCEL", comment: "The title of the cancel option when tapping the image thumbnail"), style: .cancel) { (action) in
            //
        }
        
        let takePhotoAction = UIAlertAction(title: NSLocalizedString("PHOTO_TAKE", comment: "The title of the camera option when tapping the image thumbnail"), style: .default) { (action) in
            if self.canAccessCamera() {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                print("no camera access")
            }
        }
        
        let choosePhotoAction = UIAlertAction(title: NSLocalizedString("PHOTO_CHOOSE", comment: "The title of the library option when tapping the image thumbnail"), style: .default) { (action) in
            if self.canAccessPhotos() {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                print("no photos access")
            }
        }
        
        let deletePhotoAction = UIAlertAction(title: NSLocalizedString("PHOTO_DELETE", comment: "The title of the delete option when tapping the image thumbnail"), style: .default) { (action) in
            
            let deleteController = UIAlertController(
                title: NSLocalizedString("DELETE_PHOTO_TITLE", comment: "The title of the alert for deleting a photo"),
                message: NSLocalizedString("DELETE_PHOTO_MESSAGE", comment: "The message of the alert for deleting a photo"),
                preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: NSLocalizedString("PHOTO_DELETE", comment: "The title of the delete option when tapping the image thumbnail"), style: .destructive, handler: { (action) in
                self.shouldDeleteImage = true

                // TODO: Use default image instead
                self.thumbnailImageView.image = nil
            })
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("PHOTO_CANCEL", comment: "The title of the cancel option when tapping the image thumbnail"), style: .cancel, handler: { (action) in
                //
            })
            deleteController.addAction(deleteAction)
            deleteController.addAction(cancelAction)
            
            self.present(deleteController, animated: true, completion: nil)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(takePhotoAction)
        }
        
        alertController.addAction(choosePhotoAction)
        
        if self.baby?.thumbnailImage != nil || !self.shouldDeleteImage {
            alertController.addAction(deletePhotoAction)
        }
        
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.delegate?.editBabyViewController(self, didFinishWithBaby: nil)
        
        // Delete temp image if any
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let tempUrl = urls[urls.count-1].appendingPathComponent("temp.jpg")
        do {
            try FileManager.default.removeItem(at: tempUrl)
        } catch {
            print(error)
        }
    }
    
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        
        self.baby?.givenName = self.givenNameTextField.text
        self.baby?.familyName = self.familyNameTextField.text
        self.baby?.sex = self.sexSegmentedControl.selectedSegmentIndex as NSNumber?
        
        if self.shouldDeleteImage { // Delete both temp & original images
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let url = urls[urls.count-1].appendingPathComponent((self.baby?.imageName)!)
            let tempUrl = urls[urls.count-1].appendingPathComponent("temp.jpg")

            do {
                try FileManager.default.removeItem(at: url)
                try FileManager.default.removeItem(at: tempUrl)
            } catch {
                print(error)
            }
        } else { // If there is a temp image, delete "baby.imageName" and rename temp to "baby.imageName"
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let tempUrl = urls[urls.count-1].appendingPathComponent("temp.jpg")

            if FileManager.default.fileExists(atPath: tempUrl.path) {
                let url = urls[urls.count-1].appendingPathComponent((self.baby?.imageName)!)
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    print("could not remove \(url.path)")
                }
                
                do {
                    try FileManager.default.moveItem(at: tempUrl, to: url)
                } catch {
                    print(error)
                }
            }
        }
        
        temporaryMoc?.perform({
            do {
                try self.temporaryMoc?.save()
                print("Saved child context!")
                self.moc?.perform({
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
    
    func datePickerCell(_ datePickerCell: DatePickerCell, didSelectDate date: Date) {
        if (self.visiblePickerIndexPath as NSIndexPath?)?.row == DateRow.delivery.rawValue {
            self.baby?.delivery = date
        } else if (self.visiblePickerIndexPath as NSIndexPath?)?.row == DateRow.birthday.rawValue {
            self.baby?.birthday = date
        }
    }
    
    func datePickerCellDidClear(_ datePickerCell: DatePickerCell) {
        
        if (self.visiblePickerIndexPath as NSIndexPath?)?.row == DateRow.delivery.rawValue {
            self.baby?.delivery = nil
        } else if (self.visiblePickerIndexPath as NSIndexPath?)?.row == DateRow.birthday.rawValue {
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
    
    func adultCellDidTapTypeButton(_ adultCell: AdultCell) {
        selectedIndexPath = tableView.indexPath(for: adultCell)
        self.pickAdultType()
    }
    
    func adultCellDidTapContactButton(_ adultCell: AdultCell) {
        selectedIndexPath = tableView.indexPath(for: adultCell)
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    // MARK: - CNContactPickerDelegate
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {

        if let adult: Adult = self.baby?.adultsOrdered()![(selectedIndexPath! as NSIndexPath).row] {
            adult.familyName = contact.familyName
            adult.givenName = contact.givenName
            adult.contactIdentifier = contact.identifier
            
            self.tableView.reloadSections(IndexSet(integer: Section.adults.rawValue), with: .automatic)
        } else {
            //
        }

    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        //
    }
    
    // MARK: - AdultTypePickerDelegate
    
    func adultTypePickerDidCancel(_ adultTypePicker: AdultTypeTableViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func adultTypePicker(_ adultTypePicker: AdultTypeTableViewController, didSelectType type: AdultType) {
        self.dismiss(animated: true, completion: nil)

        if let adult: Adult = self.baby?.adultsOrdered()![(selectedIndexPath! as NSIndexPath).row] {
            // TODO: Investigate if inverse relationship should also be set
            let adultType = self.temporaryMoc?.object(with: type.objectID) as! AdultType
            adult.type = adultType
            self.tableView.reloadSections(IndexSet(integer: Section.adults.rawValue), with: .automatic)
        } else {
            //
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            self.shouldDeleteImage = false

            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let url = urls[urls.count-1].appendingPathComponent("temp.jpg")
            try? UIImageJPEGRepresentation(image, 1)?.write(to: url, options: [.atomic])
            

            self.thumbnailImageView.alpha = 0
            self.thumbnailImageView.image = image
            self.dismiss(animated: true, completion: { 
                UIView.animate(withDuration: 0.3, animations: { 
                    self.thumbnailImageView.alpha = 1
                })
            })
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
