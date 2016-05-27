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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Actions
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        self.delegate?.giftViewController(self, didFinishWithGift: gift)
    }

}
