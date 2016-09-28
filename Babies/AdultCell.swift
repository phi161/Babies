//
//  AdultCell.swift
//  Babies
//
//  Created by phi161 on 13/05/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit

protocol AdultCellDelegate: class {
    func adultCellDidTapTypeButton(_ adultCell: AdultCell)
    func adultCellDidTapContactButton(_ adultCell: AdultCell)
}

class AdultCell: UITableViewCell {

    weak var delegate: AdultCellDelegate?

    @IBOutlet var typeButton: UIButton!
    @IBOutlet var contactButton: UIButton!

    @IBAction func typeButtonTapped(_ sender: AnyObject) {
        delegate?.adultCellDidTapTypeButton(self)
    }
    
    @IBAction func contactButtonTapped(_ sender: AnyObject) {
        delegate?.adultCellDidTapContactButton(self)
    }
    
}
