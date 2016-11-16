//
//  CellData.swift
//  Babies
//
//  Created by phi on 20/10/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit

struct CellData {
    var identifier: String
    var rows: Int
    var rowHeight: Float
    var selectable: Bool
    var canMove: Bool
    var shouldIndentWhileEditing: Bool
    var editingStyle: UITableViewCellEditingStyle
    var action: () -> Void
}
