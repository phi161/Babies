//
//  BabyDetailViewController.swift
//  Babies
//
//  Created by phi161 on 30/04/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit
import CoreData

class BabyDetailViewController: UIViewController, EditBabyViewControllerDelegate {

    @IBOutlet var label: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    var baby:Baby? = nil
    var moc: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(editButtonTapped(_:)))
        
        self.label.text = self.baby?.stringRepresentation()
        self.imageView.image = self.baby?.thumbnailImage
    }
    
    func editButtonTapped(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let editBabyViewController = storyboard.instantiateViewControllerWithIdentifier("EditBabyViewControllerId") as? EditBabyViewController {
            let navigationController = UINavigationController(rootViewController: editBabyViewController)
            navigationController.modalTransitionStyle = .CrossDissolve
            self.presentViewController(navigationController, animated: true, completion: nil)
            editBabyViewController.delegate = self
            editBabyViewController.moc = self.moc
            editBabyViewController.babyObjectId = self.baby?.objectID
        }
    }
    
    func editBabyViewController(editBabyViewController: EditBabyViewController, didFinishWithBaby baby: Baby?) {
        self.dismissViewControllerAnimated(true) {
            dispatch_async(dispatch_get_main_queue(), { 
                self.imageView.image = self.baby?.thumbnailImage
                self.label.text = self.baby?.stringRepresentation()
            })
        }
    }
    
}
