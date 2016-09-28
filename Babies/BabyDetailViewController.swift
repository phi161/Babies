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
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped(_:)))
        
        self.label.text = self.baby?.stringRepresentation()
        self.imageView.image = self.baby?.thumbnailImage
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
                self.imageView.image = self.baby?.thumbnailImage
                self.label.text = self.baby?.stringRepresentation()
            })
        }
    }
    
}
