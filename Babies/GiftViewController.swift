//
//  GiftViewController.swift
//  Babies
//
//  Created by phi161 on 27/05/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit

protocol GiftViewControllerDelegate: class {
    func giftViewController(_ giftViewController: GiftViewController, didFinishWithGift gift: Gift)
}

class GiftViewController: UIViewController {
    
    @IBOutlet var detailsTextView: UITextView!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var currencyLabel: UILabel!
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
        
        self.title = NSLocalizedString("GIFT_VIEW_TITLE", comment: "The title of the Gift detail view")
        
        self.currencyLabel.text = Locale.current.currencySymbol ?? "€"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(doneButtonTapped(_:)))
        
        self.dateLabel.text = NSLocalizedString("GIFT_DATE_TITLE", comment: "The text above the gift date picker")
        self.datePicker.date = gift.date! as Date
        
        self.detailsTextView.text = gift.details
        
        self.priceTextField.placeholder = NSLocalizedString("GIFT_PRICE_PLACEHOLDER", comment: "Placeholder text for the gift price textfield")
        self.priceTextField.text = gift.price?.stringValue
        
        // Keyboard toolbar
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(GiftViewController.hideKeyboard))
        ]
        
        self.priceTextField.inputAccessoryView = toolbar
        self.detailsTextView.inputAccessoryView = toolbar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Actions
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        hideKeyboard()
        
        gift.date = self.datePicker.date
        gift.details = self.detailsTextView.text
        gift.price = (self.priceTextField.text! as NSString).floatValue as NSNumber?
        
        self.delegate?.giftViewController(self, didFinishWithGift: gift)
    }

}
