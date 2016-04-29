//
//  BabyDetailViewController.swift
//  Babies
//
//  Created by phi161 on 30/04/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit

class BabyDetailViewController: UIViewController, EditBabyViewControllerDelegate {

    @IBOutlet var label: UILabel!
    
    var baby:Baby? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(editButtonTapped(_:)))
        
        self.label.text = self.baby?.stringRepresentation()
    }
    
    func editButtonTapped(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let editBabyViewController = storyboard.instantiateViewControllerWithIdentifier("EditBabyViewControllerId") as? EditBabyViewController {
            let navigationController = UINavigationController(rootViewController: editBabyViewController)
            navigationController.modalTransitionStyle = .CrossDissolve
            self.presentViewController(navigationController, animated: true, completion: nil)
            editBabyViewController.delegate = self
        }
    }
    
    func editBabyViewController(editBabyViewController: EditBabyViewController, didAddBaby baby: Baby?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
