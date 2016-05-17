//
//  AdultTypeTableViewController.swift
//  Babies
//
//  Created by phi161 on 17/05/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit

protocol AdultTypePickerDelegate: class {
    func adultTypePicker(adultTypePicker: AdultTypeTableViewController, didSelectType type:AdultType)
    func adultTypePickerDidCancel(adultTypePicker: AdultTypeTableViewController)
}

class AdultTypeTableViewController: UITableViewController {
    
    var adultType: AdultType?
    weak var delegate: AdultTypePickerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("AdultTypeCellIdentifier", forIndexPath: indexPath)
        
        cell.textLabel?.text = "\(indexPath.section) - \(indexPath.row)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.adultTypePickerDidCancel(self)
    }

}
