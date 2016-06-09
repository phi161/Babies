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
    func datePickerCell(datePickerCell: DatePickerCell, didSelectDate date:NSDate)
}

class DatePickerCell: UITableViewCell, UIPickerViewDelegate {
    
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var clearButton: UIButton!
    @IBOutlet var clearButtonTrailingConstraint: NSLayoutConstraint!
    
    weak var delegate: DatePickerCellDelegate?
    
    private var isExpanded = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.clearButton.setTitle(NSLocalizedString("CLEAR_BUTTON", comment: "The title of the clear button"), forState: .Normal)
        
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
    
    func configure(withTitle title: String, date: NSDate?, mode: UIDatePickerMode) {
        
        self.titleLabel.text = title
        
        self.datePicker.datePickerMode = mode
        
        if date != nil {
            self.dateLabel.text = NSDateFormatter.localizedStringFromDate(date!, dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        } else {
            self.dateLabel.text = NSLocalizedString("EMPTY_DATE", comment: "The text of the date label when no date is selected")
        }
    }

    @IBAction func datePickerChanged(sender: UIDatePicker) {
        self.dateLabel.text = NSDateFormatter.localizedStringFromDate(sender.date, dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        delegate?.datePickerCell(self, didSelectDate: sender.date)
    }
    
    @IBAction func clearButtonTapped(sender: AnyObject) {
        self.dateLabel.text = NSLocalizedString("EMPTY_DATE", comment: "The text of the date label when no date is selected")
        delegate?.datePickerCellDidClear(self)
    }
    
}
