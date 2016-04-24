//
//  DatePickerCell.swift
//  Babies
//
//  Created by phi161 on 24/04/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit

protocol DatePickerDelegate: class {
    func didPickDate(date: NSDate)
}

class DatePickerCell: UITableViewCell, UIPickerViewDelegate {
    
    @IBOutlet var datePicker: UIDatePicker!

    weak var delegate: DatePickerDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func datePickerChanged(sender: UIDatePicker) {
        self.delegate?.didPickDate(sender.date)
    }
}
