//
//  GiftCell.swift
//  Babies
//
//  Created by phi161 on 27/05/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit

class GiftCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var currencyLabel: UILabel!

    
    func updateInterface(gift: Gift) {
        let textPrompt = NSLocalizedString("TAP_TO_EDIT_GIFT", comment: "Prompt text when the gift details is nil or empty")
        titleLabel.text = (gift.details ?? "").isEmpty ? textPrompt : gift.details!
        if let date = gift.date {
            dateLabel.text = NSDateFormatter.localizedStringFromDate(date, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        } else {
            dateLabel.text = "n/a"
        }
        currencyLabel.text = gift.price?.stringValue
    }
}
