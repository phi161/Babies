//
//  BabyDetailViewController.swift
//  Babies
//
//  Created by phi161 on 30/04/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit
import CoreData

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
        if section == Section.adults.rawValue {
            if let adultsCount = self.baby?.adults?.count, adultsCount > 0 {
                return adultsCount
            }
        } else if section == Section.gifts.rawValue {
            if let giftsCount = self.baby?.gifts?.count, giftsCount > 0 {
                return giftsCount
            }
        }
        
        return 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeaderTitles[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "generic")!

        if indexPath.section == Section.adults.rawValue {
            if let adultsCount = self.baby?.adults?.count, adultsCount > 0 {
                if let adult = self.baby?.adultsOrdered()![indexPath.row] {
                    cell.textLabel?.text = adult.name()
                    cell.detailTextLabel?.text = adult.type?.title
                }
            } else {
                cell.textLabel?.text = "no adults"
            }
        } else if indexPath.section == Section.gifts.rawValue {
            if let giftsCount = self.baby?.gifts?.count, giftsCount > 0 {
                if let gift = self.baby?.giftsOrdered()![indexPath.row] {
                    cell.textLabel?.text = gift.details
                }
            } else {
                cell.textLabel?.text = "no gifts"
            }
        }
        
        return cell
    }

    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
}
