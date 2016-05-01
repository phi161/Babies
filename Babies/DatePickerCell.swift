//
//  DatePickerCell.swift
//  Babies
//
//  Created by phi161 on 24/04/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit

class DatePickerCell: UITableViewCell, UIPickerViewDelegate {
    
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var clearButton: UIButton!
    @IBOutlet var clearButtonTrailingConstraint: NSLayoutConstraint!
    var isExpanded = true //
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            isExpanded = !isExpanded
            
            if isExpanded {
                self.clearButtonTrailingConstraint.constant = 0
                self.dateLabel.textColor = UIColor.redColor()
            } else {
                self.clearButtonTrailingConstraint.constant = -64
                self.dateLabel.textColor = UIColor.blueColor()
            }
            UIView.animateWithDuration(0.3) {
                self.contentView.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func datePickerChanged(sender: UIDatePicker) {
        self.dateLabel.text = NSDateFormatter.localizedStringFromDate(sender.date, dateStyle: .MediumStyle, timeStyle: .ShortStyle)
    }
    
    @IBAction func clearButtonTapped(sender: AnyObject) {
        //
    }
    
}
