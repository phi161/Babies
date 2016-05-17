//
//  AdultTypeTableViewController.swift
//  Babies
//
//  Created by phi161 on 17/05/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit

class AdultTypeTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("AdultTypeCellIdentifier", forIndexPath: indexPath)
        
        cell.textLabel?.text = "\(indexPath.section) - \(indexPath.row)"
        
        return cell
    }

}
