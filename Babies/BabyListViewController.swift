//
//  BabyListViewController.swift
//  Babies
//
//  Created by phi on 06/01/2020.
//  Copyright © 2020 phi161. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class BabyListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private let disposeBag = DisposeBag()
    private let provider = CoreDataBabyProvider()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        provider.babies()
            .map{$0.sorted{$0.lastName > $1.lastName}} // convert Set to a sorted Array
            .bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = "\(element) @ row \(row)"
            }
            .disposed(by: disposeBag)
    }

}
