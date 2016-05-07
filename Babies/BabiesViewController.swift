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
    
    var moc: NSManagedObjectContext?
    var babies: [Baby] {
        let fetchRequest = NSFetchRequest(entityName: "Baby")
        var result:[Baby]
        do {
            try result = self.moc?.executeFetchRequest(fetchRequest) as! [Baby]
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return babies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BabyListCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = babies[indexPath.row].stringRepresentation()
        
        return cell
    }
    
    // MARK: - EditBabyViewControllerDelegate
    
    func editBabyViewController(editBabyViewController: EditBabyViewController, didFinishWithBaby baby: Baby?) {
        self.dismissViewControllerAnimated(true) { 
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "SegueAddNewBaby" {
            let navigationController = segue.destinationViewController as? UINavigationController
            let editBabyViewController: EditBabyViewController = navigationController?.viewControllers.first as! EditBabyViewController
            
            editBabyViewController.moc = self.moc
            editBabyViewController.delegate = self
            editBabyViewController.isAddingNewEntity = true
        } else if segue.identifier == "SegueShowBabyDetail" {
            let babyDetailViewController = segue.destinationViewController as? BabyDetailViewController
            
            let selectedIndexPath = self.tableView.indexPathForSelectedRow
            babyDetailViewController?.moc = self.moc
            babyDetailViewController?.baby = babies[(selectedIndexPath?.row)!]
        }
    }
    
}
