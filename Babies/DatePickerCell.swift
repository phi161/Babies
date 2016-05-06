//
//  DatePickerCell.swift
//  Babies
//
//  Created by phi161 on 24/04/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit

protocol DatePickerCellDelegate: class {
    func datePickerCellDidClear(datePickerCell: DatePickerCell)
}

class DatePickerCell: UITableViewCell, UIPickerViewDelegate {
    
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var clearButton: UIButton!
    @IBOutlet var clearButtonTrailingConstraint: NSLayoutConstraint!
    
    weak var delegate: DatePickerCellDelegate?
    
    private var isExpanded = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.clearButtonTrailingConstraint.constant = -64
        self.dateLabel.textColor = UIColor.blueColor()
    }
    
    func setExpanded(expanded: Bool, animated: Bool) {
        
        var duration = 0.0
        if animated == true {
            duration = 0.3
        }

        if expanded {
            if isExpanded {
                // do nothing
            } else {
                // expand
                self.clearButtonTrailingConstraint.constant = 0
                self.dateLabel.textColor = UIColor.redColor()
                
                UIView.animateWithDuration(duration) {
                    self.contentView.layoutIfNeeded()
                }
                
                isExpanded = true

            }
        } else {
            if isExpanded {
                // collapse
                self.clearButtonTrailingConstraint.constant = -64
                self.dateLabel.textColor = UIColor.blueColor()
                
                UIView.animateWithDuration(duration) {
                    self.contentView.layoutIfNeeded()
                }
                
                isExpanded = false

            } else {
                // do nothing
            }
        }
    }

    @IBAction func datePickerChanged(sender: UIDatePicker) {
        self.dateLabel.text = NSDateFormatter.localizedStringFromDate(sender.date, dateStyle: .MediumStyle, timeStyle: .ShortStyle)
    }
    
    @IBAction func clearButtonTapped(sender: AnyObject) {
        delegate?.datePickerCellDidClear(self)
    }
    
}
