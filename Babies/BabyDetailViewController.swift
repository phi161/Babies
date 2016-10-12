//
//  BabyDetailViewController.swift
//  Babies
//
//  Created by phi161 on 30/04/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit
import CoreData

struct CellData {
    var identifier: String
    var rows: Int
}

class BabyDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EditBabyViewControllerDelegate {
    
    enum Section: Int {
        case adults, gifts
    }

    let sectionHeaderTitles = [
        NSLocalizedString("SECTION_TITLE_ADULTS", comment: "The section title for adults"),
        NSLocalizedString("SECTION_TITLE_GIFTS", comment: "The section title for gifts")
    ]

    @IBOutlet var tableView: UITableView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    var baby:Baby? = nil
    var moc: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped(_:)))
        
        self.tableView.register(UINib.init(nibName: "GiftCell", bundle: nil), forCellReuseIdentifier: "GiftCellIdentifier")
    }
    
    override func viewDidLayoutSubviews() {
        if baby != nil {
            self.nameLabel.text = "\(self.baby!.fullName())\n\(self.baby!.birthdayString())"
            self.imageView.image = self.baby!.thumbnailImage
        }
    }
    
    func editButtonTapped(_ sender: AnyObject) {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellData(indexPath: IndexPath(row: 0, section: section)).rows
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeaderTitles[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let identifier = self.cellData(indexPath: indexPath).identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == Section.adults.rawValue {
            if let adultsCount = self.baby?.adults?.count, adultsCount > 0 {
                if let adult = self.baby?.adultsOrdered()![indexPath.row] {
                    cell.textLabel?.text = adult.name()
                    cell.detailTextLabel?.text = adult.type?.title
                }
            } else {
                cell.textLabel?.text = "no adults"
                cell.detailTextLabel?.text = ""
            }
        } else if indexPath.section == Section.gifts.rawValue {
            if let giftsCount = self.baby?.gifts?.count, giftsCount > 0 {
                if let gift = self.baby?.giftsOrdered()![indexPath.row] {
                    if let c = cell as? GiftCell {
                        c.updateInterface(gift)
                    }
                }
            } else {
                cell.textLabel?.text = "no gifts"
                cell.detailTextLabel?.text = ""
            }
        }
    }

    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
    
    // MARK: - Helpers
    
    func cellData(indexPath: IndexPath) -> CellData {
        var cellData = CellData(identifier: "generic", rows: 0)
        
        switch indexPath.section {
        case Section.adults.rawValue:
            if let adultsCount = self.baby?.adults?.count, adultsCount > 0 {
                cellData = CellData(identifier: "generic", rows: adultsCount)
            } else {
                cellData = CellData(identifier: "generic", rows: 1)
            }
        case Section.gifts.rawValue:
            if let giftsCount = self.baby?.gifts?.count, giftsCount > 0 {
                cellData = CellData(identifier: "GiftCellIdentifier", rows: giftsCount)
            } else {
                cellData = CellData(identifier: "generic", rows: 1)
            }
        default:
            break
        }
        
        return cellData
    }
}
