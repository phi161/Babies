//
//  BabyDetailViewController.swift
//  Babies
//
//  Created by phi161 on 30/04/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit

class BabyDetailViewController: UIViewController {

    @IBOutlet var label: UILabel!
    
    var baby:Baby? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.label.text = self.baby?.stringRepresentation()
    }
}
