//
//  ViewController.swift
//  Babies
//
//  Created by phi161 on 07/04/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit
import CoreData

class BabiesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EditBabyViewControllerDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var selectedIndexPath: IndexPath?
    var moc: NSManagedObjectContext?
    var babies: [Baby] {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Baby")
        var result:[Baby]
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = selectedIndexPath {
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return babies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BabyListCell", for: indexPath)
        
        cell.imageView?.image = babies[(indexPath as NSIndexPath).row].thumbnailImage
        cell.textLabel?.text = babies[(indexPath as NSIndexPath).row].stringRepresentation()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let baby = babies[indexPath.row]
            self.moc?.delete(baby)
            tableView.deleteRows(at: [indexPath], with: .middle)
            
            self.moc?.perform({
                do {
                    try self.moc?.save()
                    print("Saved main context")
                } catch {
                    print("Error for main: \(error)")
                }
            })
        }
    }
    
    // MARK: - EditBabyViewControllerDelegate
    
    func editBabyViewController(_ editBabyViewController: EditBabyViewController, didFinishWithBaby baby: Baby?) {
        self.dismiss(animated: true) { 
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SegueAddNewBaby" {
            selectedIndexPath = nil
            
            let navigationController = segue.destination as? UINavigationController
            let editBabyViewController: EditBabyViewController = navigationController?.viewControllers.first as! EditBabyViewController
            
            editBabyViewController.moc = self.moc
            editBabyViewController.delegate = self
            editBabyViewController.isAddingNewEntity = true
        } else if segue.identifier == "SegueShowBabyDetail" {
            let babyDetailViewController = segue.destination as? BabyDetailViewController
            
            selectedIndexPath = self.tableView.indexPathForSelectedRow
            babyDetailViewController?.moc = self.moc
            babyDetailViewController?.baby = babies[(selectedIndexPath?.row)!]
        }
    }
    
}
