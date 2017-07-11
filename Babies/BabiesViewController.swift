//
//  ViewController.swift
//  Babies
//
//  Created by phi161 on 07/04/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit
import CoreData

class BabiesViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var emptyLabel: UILabel!
    
    var selectedIndexPath: IndexPath?
    var moc: NSManagedObjectContext?
    var babies: [Baby] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Baby")
        var result: [Baby]
        do {
            try result = self.moc?.fetch(fetchRequest) as! [Baby]
        } catch {
            result = []
            print("Error: \(error)")
        }
        
        return result
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyLabel.text = NSLocalizedString("NO_BABIES", comment: "The text that replaces an empty list")
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.register(UINib.init(nibName: "BabyCell", bundle: nil), forCellReuseIdentifier: "BabyCellIdentifier")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        checkEmpty()
        
        if let indexPath = selectedIndexPath {
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - Actions
    
    func deleteBaby(atIndex index: Int) {
        let alertController = UIAlertController(title: NSLocalizedString("DELETE_BABY_TITLE", comment: "The title of the actionsheet when attempting to delete a baby"), message: NSLocalizedString("DELETE_BABY_MESSAGE", comment: "The message of the actionsheet when attempting to delete a baby"), preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("DELETE_BABY_CANCEL_BUTTON", comment: "The title of the button that cancels the deletion"), style: .cancel) { _ in
            self.tableView.setEditing(false, animated: true)
        }
        
        let deleteAction = UIAlertAction(title: NSLocalizedString("DELETE_BABY_DELETE_BUTTON", comment: "The title of the button that actually deletes"), style: .destructive) { _ in
            let baby = self.babies[index]
            self.moc?.delete(baby)
            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .middle)
            
            self.moc?.perform({
                do {
                    try self.moc?.save()
                    print("Saved main context")
                } catch {
                    print("Error for main: \(error)")
                }
            })
            
            self.checkEmpty()
        }
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SegueAddNewBaby" {
            selectedIndexPath = nil
            
            let navigationController = segue.destination as? UINavigationController
            guard let editBabyViewController = navigationController?.viewControllers.first as? EditBabyViewController else {
                fatalError("Got the wrong view controller")
            }
            editBabyViewController.moc = self.moc
            editBabyViewController.delegate = self
            editBabyViewController.isAddingNewEntity = true
        }
    }
    
    func checkEmpty() {
        if babies.count == 0 {
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.alpha = 0
            })
        } else {
            tableView.alpha = 1.0
        }
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension BabiesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return babies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "BabyCellIdentifier", for: indexPath) as? BabyCell {
            let baby = babies[indexPath.row]
            cell.configure(for: baby)
            return cell
        }
        
        return UITableViewCell(style: .default, reuseIdentifier: "default")
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteBaby(atIndex: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let babyDetailViewController = storyboard.instantiateViewController(withIdentifier: "BabyDetailViewControllerId") as? BabyDetailViewController {
            selectedIndexPath = self.tableView.indexPathForSelectedRow
            babyDetailViewController.moc = self.moc
            babyDetailViewController.baby = babies[(selectedIndexPath?.row)!]
            self.navigationController?.pushViewController(babyDetailViewController, animated: true)
        }
    }
}

// MARK: - EditBabyViewControllerDelegate
extension BabiesViewController: EditBabyViewControllerDelegate {
    func editBabyViewController(_ editBabyViewController: EditBabyViewController, didFinishWithBaby baby: Baby?) {
        checkEmpty()
        self.dismiss(animated: true) {
            self.tableView.reloadData()
        }
    }
}
