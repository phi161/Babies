//
//  DatePickerCell.swift
//  Babies
//
//  Created by phi161 on 24/04/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit

protocol DatePickerCellDelegate: class {
    func datePickerCellDidClear(_ datePickerCell: DatePickerCell)
    func datePickerCell(_ datePickerCell: DatePickerCell, didSelectDate date: Date)
}

class DatePickerCell: UITableViewCell, UIPickerViewDelegate {

    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var clearButton: UIButton!
    @IBOutlet var clearButtonTrailingConstraint: NSLayoutConstraint!

    weak var delegate: DatePickerCellDelegate?

    fileprivate var isExpanded = false

    override func awakeFromNib() {
        super.awakeFromNib()

        clearButton.setTitle(NSLocalizedString("CLEAR_BUTTON", comment: "The title of the clear button"), for: .normal)

        clearButtonTrailingConstraint.constant = -64
        dateLabel.textColor = .blue
    }

    func setExpanded(_ expanded: Bool, animated: Bool) {

        var duration = 0.0
        if animated == true {
            duration = 0.3
        }

        if expanded {
            if isExpanded {
                // do nothing
            } else {
                // expand
                clearButtonTrailingConstraint.constant = 0

                UIView.animate(withDuration: duration, animations: {
                    self.contentView.layoutIfNeeded()
                })

                isExpanded = true

            }
        } else {
            if isExpanded {
                // collapse
                clearButtonTrailingConstraint.constant = -64
                dateLabel.textColor = UIColor.blue

                UIView.animate(withDuration: duration, animations: {
                    self.contentView.layoutIfNeeded()
                })

                isExpanded = false

            } else {
                // do nothing
            }
        }
    }

    func configure(withTitle title: String, date: Date?, mode: UIDatePickerMode) {

        titleLabel.text = title

        datePicker.datePickerMode = mode

        if date != nil {
            dateLabel.text = DateFormatter.localizedString(from: date!, dateStyle: .medium, timeStyle: .short)
        } else {
            dateLabel.text = NSLocalizedString("EMPTY_DATE", comment: "The text of the date label when no date is selected")
        }
    }

    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        dateLabel.text = DateFormatter.localizedString(from: sender.date, dateStyle: .medium, timeStyle: .short)
        delegate?.datePickerCell(self, didSelectDate: sender.date)
    }

    @IBAction func clearButtonTapped(_ sender: AnyObject) {
        dateLabel.text = NSLocalizedString("EMPTY_DATE", comment: "The text of the date label when no date is selected")
        delegate?.datePickerCellDidClear(self)
    }

}
