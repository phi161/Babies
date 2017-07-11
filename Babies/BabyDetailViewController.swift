//
//  BabyDetailViewController.swift
//  Babies
//
//  Created by phi161 on 30/04/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit
import CoreData
import Contacts
import ContactsUI

class BabyDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EditBabyViewControllerDelegate {
    
    enum Section: Int {
        case adults, gifts, notes
    }
    
    let sectionHeaderTitles = [
        NSLocalizedString("SECTION_TITLE_ADULTS", comment: "The section title for adults"),
        NSLocalizedString("SECTION_TITLE_GIFTS", comment: "The section title for gifts"),
        NSLocalizedString("SECTION_TITLE_NOTES", comment: "The section title for notes")
    ]
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    var baby: Baby?
    var moc: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped(_:)))
        
        self.tableView.register(UINib.init(nibName: "GiftCell", bundle: nil), forCellReuseIdentifier: "GiftCellIdentifier")
        self.tableView.register(UINib.init(nibName: "NoteCell", bundle: nil), forCellReuseIdentifier: "NoteCellIdentifier")
        
        tableView.estimatedRowHeight = 100 // Needed for calculating automatically the textView's height
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let selectedIndexPath = self.tableView.indexPathForSelectedRow else { return }
        self.tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        if baby != nil {
            self.nameLabel.text = "\(self.baby!.fullName())\n\(self.baby!.birthdayString())"
            self.imageView.image = self.baby!.thumbnailImage
        }
    }
    
    @objc func editButtonTapped(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let editBabyViewController = storyboard.instantiateViewController(withIdentifier: "EditBabyViewControllerId") as? EditBabyViewController {
            let navigationController = UINavigationController(rootViewController: editBabyViewController)
            navigationController.modalTransitionStyle = .crossDissolve
            self.present(navigationController, animated: true, completion: nil)
            editBabyViewController.delegate = self
            editBabyViewController.moc = self.moc
            editBabyViewController.babyObjectId = self.baby?.objectID
        }
    }
    
    func editBabyViewController(_ editBabyViewController: EditBabyViewController, didFinishWithBaby baby: Baby?) {
        self.dismiss(animated: true) {
            DispatchQueue.main.async(execute: {
                // Update GUI
                self.tableView.reloadData()
                if baby != nil {
                    self.nameLabel.text = "\(self.baby!.fullName())\n\(self.baby!.birthdayString())"
                    self.imageView.image = self.baby!.thumbnailImage
                }
            })
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionHeaderTitles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(self.cellData(indexPath: indexPath).rowHeight)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellData(indexPath: IndexPath(row: 0, section: section)).rows
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == Section.gifts.rawValue {
            if (baby?.gifts?.count)! > 0 {
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.locale = Locale.current
                if let price = baby?.giftsTotalPrice(), let currencyPrice = formatter.string(from: price) {
                    return "\(NSLocalizedString("SECTION_TITLE_GIFTS", comment: "The section title for gifts")) \(currencyPrice)"
                }
            }
        }
        return sectionHeaderTitles[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = self.cellData(indexPath: indexPath).identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.selectionStyle = self.cellData(indexPath: indexPath).selectable == true ? .blue : .none
        cell.accessoryType = self.cellData(indexPath: indexPath).selectable == true ? .disclosureIndicator : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.cellData(indexPath: indexPath).willDisplayConfiguration(cell)
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.cellData(indexPath: indexPath).action()
    }
    
    // MARK: - Helpers
    
    func cellData(indexPath: IndexPath) -> CellData {
        var cellData = CellData()
        
        switch indexPath.section {
        case Section.adults.rawValue:
            if let adultsCount = self.baby?.adults?.count, adultsCount > 0 {
                cellData = CellData(identifier: "generic", rows: adultsCount, rowHeight: 60, selectable: true, canMove: false, shouldIndentWhileEditing: false, editingStyle: .none, action: {
                    print("adult \(indexPath.row)")
                    DispatchQueue.global(qos: .userInitiated).async {
                        let store = CNContactStore()
                        let adult = self.baby?.adultsOrdered()?[indexPath.row]
                        let contact = try? store.unifiedContact(withIdentifier: (adult?.contactIdentifier)!, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
                        let viewController = CNContactViewController(for: contact!)
                        viewController.contactStore = store
                        DispatchQueue.main.async {
                            self.navigationController?.pushViewController(viewController, animated: true)
                        }
                    }
                    }, willDisplayConfiguration: { cell in
                        if let adult = self.baby?.adultsOrdered()![indexPath.row] {
                            cell.textLabel?.text = adult.name()
                            cell.detailTextLabel?.text = adult.type?.title
                        }
                })
            } else {
                cellData = CellData(identifier: "generic", rows: 1, rowHeight: 20, selectable: false, canMove: false, shouldIndentWhileEditing: false, editingStyle: .none, action: {
                    print("no adult")
                    }, willDisplayConfiguration: { cell in
                        cell.textLabel?.text = "no adults"
                        cell.detailTextLabel?.text = ""
                })
            }
        case Section.gifts.rawValue:
            if let giftsCount = self.baby?.gifts?.count, giftsCount > 0 {
                cellData = CellData(identifier: "GiftCellIdentifier", rows: giftsCount, rowHeight: 80, selectable: false, canMove: false, shouldIndentWhileEditing: false, editingStyle: .none, action: {
                    print("gift \(indexPath.row)")
                    }, willDisplayConfiguration: { cell in
                        if let gift = self.baby?.giftsOrdered()![indexPath.row] {
                            if let c = cell as? GiftCell {
                                c.updateInterface(gift)
                            }
                        }
                })
            } else {
                cellData = CellData(identifier: "generic", rows: 1, rowHeight: 20, selectable: false, canMove: false, shouldIndentWhileEditing: false, editingStyle: .none, action: {
                    print("no gift")
                    }, willDisplayConfiguration: { cell in
                        cell.textLabel?.text = "no gifts"
                        cell.detailTextLabel?.text = ""
                })
            }
        case Section.notes.rawValue:
            cellData = CellData(identifier: "NoteCellIdentifier", rows: 1, rowHeight: UITableViewAutomaticDimension, selectable: false, canMove: false, shouldIndentWhileEditing: false, editingStyle: .none, action: {}, willDisplayConfiguration: { cell in
                if let cell = cell as? NoteCell {
                    cell.baby = self.baby
                    cell.editable = false
                    cell.updateInterface()
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                }
            })
        default:
            break
        }
        
        return cellData
    }
}
