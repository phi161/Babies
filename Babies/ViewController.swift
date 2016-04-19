//
//  ViewController.swift
//  Babies
//
//  Created by phi161 on 07/04/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    var moc: NSManagedObjectContext?
    var babies = [Baby]()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = NSFetchRequest(entityName: "Baby")
        do {
            try babies = self.moc?.executeFetchRequest(fetchRequest) as! [Baby]
        } catch {
            print("Error: \(error)")
        }
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
        cell.detailTextLabel?.text = NSDateFormatter.localizedStringFromDate(babies[indexPath.row].birthday!, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        
        return cell
    }
    
    // MARK: - Actions
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navigationController = segue.destinationViewController as? UINavigationController
        let editBabyViewController: EditBabyViewController = navigationController?.viewControllers.first as! EditBabyViewController
        
        editBabyViewController.moc = self.moc
    }
    
    @IBAction func newButtonTapped(sender: AnyObject) {
        let newBaby: Baby = NSEntityDescription.insertNewObjectForEntityForName("Baby", inManagedObjectContext: self.moc!) as! Baby
        newBaby.birthday = NSDate()
        newBaby.givenName = "Given"
        newBaby.familyName = "Family"
        
        do {
            try moc?.save()
            print("Saved \(newBaby.stringRepresentation())")
        } catch {
            print("Error: \(error)")
        }
    }
}

