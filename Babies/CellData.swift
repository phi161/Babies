//
//  CellData.swift
//  Babies
//
//  Created by phi on 20/10/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit

struct CellData {
    var identifier = ""
    var rows = 0
    var rowHeight: CGFloat = 44.0
    var selectable = false
    var canMove = false
    var shouldIndentWhileEditing = false
    var editingStyle: UITableViewCellEditingStyle = .none
    var action: () -> Void = {}
    var willDisplayConfiguration: (_ cell: UITableViewCell) -> Void = { _ in }
}
