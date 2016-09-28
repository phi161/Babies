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
        
        self.tableView.reloadData()
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
    
    // MARK: - EditBabyViewControllerDelegate
    
    func editBabyViewController(_ editBabyViewController: EditBabyViewController, didFinishWithBaby baby: Baby?) {
        self.dismiss(animated: true) { 
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SegueAddNewBaby" {
            let navigationController = segue.destination as? UINavigationController
            let editBabyViewController: EditBabyViewController = navigationController?.viewControllers.first as! EditBabyViewController
            
            editBabyViewController.moc = self.moc
            editBabyViewController.delegate = self
            editBabyViewController.isAddingNewEntity = true
        } else if segue.identifier == "SegueShowBabyDetail" {
            let babyDetailViewController = segue.destination as? BabyDetailViewController
            
            let selectedIndexPath = self.tableView.indexPathForSelectedRow
            babyDetailViewController?.moc = self.moc
            babyDetailViewController?.baby = babies[((selectedIndexPath as NSIndexPath?)?.row)!]
        }
    }
    
}
