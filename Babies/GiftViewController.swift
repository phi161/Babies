//
//  GiftViewController.swift
//  Babies
//
//  Created by phi161 on 27/05/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit

protocol GiftViewControllerDelegate: class {
    func giftViewController(giftViewController: GiftViewController, didFinishWithGift gift: Gift)
}

class GiftViewController: UIViewController {
    
    @IBOutlet var detailsTextView: UITextView!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var priceTextField: UITextField!

    var gift: Gift
    weak var delegate: GiftViewControllerDelegate?
    
    // MARK: - Setup
    
    init(gift: Gift) {
        self.gift = gift
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(doneButtonTapped(_:)))
        
        self.datePicker.date = gift.date!
        self.detailsTextView.text = gift.details
        self.priceTextField.text = gift.price?.stringValue
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Actions
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        gift.date = self.datePicker.date
        gift.details = self.detailsTextView.text
        gift.price = (self.priceTextField.text! as NSString).floatValue
        
        self.delegate?.giftViewController(self, didFinishWithGift: gift)
    }

}
