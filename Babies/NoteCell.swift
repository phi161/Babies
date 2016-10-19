//
//  NoteCell.swift
//  Babies
//
//  Created by phi on 19/10/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet var textView: UITextView!
    var baby: Baby?
    
    func textViewDidChange(_ textView: UITextView) {
        baby?.notes = self.textView.text
    }
    
    func updateInterface() {
        if let text = self.baby?.notes {
            self.textView.text = text
        } else {
            self.textView.text = "default"
        }
    }
}
