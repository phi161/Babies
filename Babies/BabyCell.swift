//
//  BabyCell.swift
//  Babies
//
//  Created by phi on 27/11/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit

class BabyCell: UITableViewCell {

    @IBOutlet var thumbnail: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var adultsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
