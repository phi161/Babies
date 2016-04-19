//
//  EditBabyViewController.swift
//  Babies
//
//  Created by phi161 on 19/04/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit
import CoreData

class EditBabyViewController: UIViewController {
    
    var moc: NSManagedObjectContext?

    @IBOutlet var familyNameTextField: UITextField!
    
    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.redColor()
        
        self.title = NSLocalizedString("NEW_BABY_TITLE", comment: "The title of the new baby view controller")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Actions
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let newBaby: Baby = NSEntityDescription.insertNewObjectForEntityForName("Baby", inManagedObjectContext: self.moc!) as! Baby
        newBaby.birthday = NSDate()
        newBaby.givenName = "Given"
        newBaby.familyName = self.familyNameTextField.text
        
        do {
            try moc?.save()
            print("Saved \(newBaby.stringRepresentation())")
        } catch {
            print("Error: \(error)")
        }
    }
}
