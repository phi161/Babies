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

    
    func updateInterface(_ gift: Gift) {
        
        // Details
        let textPrompt = NSLocalizedString("TAP_TO_EDIT_GIFT", comment: "Prompt text when the gift details is nil or empty")
        titleLabel.text = (gift.details ?? "").isEmpty ? textPrompt : gift.details!
        
        // Date
        if let date = gift.date {
            dateLabel.text = DateFormatter.localizedString(from: date as Date, dateStyle: .long, timeStyle: .none)
        } else {
            dateLabel.text = "n/a"
        }
        
        // Price
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        
        currencyLabel.text = formatter.string(from: gift.price!)
    }
}
