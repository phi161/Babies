//
//  BabyCell.swift
//  Babies
//
//  Created by phi on 27/11/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit

class BabyCell: UITableViewCell {

    @IBOutlet var thumbnailBackground: UIView!
    @IBOutlet var thumbnail: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var adultsLabel: UILabel!

}

extension BabyCell {
    func configure(for baby: Baby) {
        thumbnailBackground.backgroundColor = baby.color
        thumbnail.image = baby.thumbnailImage
        nameLabel.text = baby.fullName()
        dateLabel.attributedText = baby.iconDateStringRepresentation
        adultsLabel.text = baby.adultsStringRepresentation
    }
}
