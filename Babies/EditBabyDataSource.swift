//
//  EditBabyDataSource.swift
//  Babies
//
//  Created by phi161 on 28/04/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit

class EditBabyDataSource: NSObject, UITableViewDataSource {

    let sectionHeaderTitles = [
        "Dates",
        /*
         "Parents",
         "Gifts",
         "Events",
         */
    ]
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sectionHeaderTitles.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        
        return 1
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionHeaderTitles[section]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifer: String = "DatePickerCell"
        
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(identifer)!
        
        return cell
    }
    
}
