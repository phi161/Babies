//
//  ViewController.swift
//  Babies
//
//  Created by phi on 05/01/2020.
//  Copyright © 2020 phi161. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func buttonTapped(_ sender: Any) {
        showBabyListViewController()
    }

    private func showBabyListViewController() {
        let vc = BabyListViewController(nibName: nil, bundle: nil)
        present(vc, animated: true, completion: nil)
    }


}
