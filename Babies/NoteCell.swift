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
    
    var editable: Bool = true {
        didSet {
            self.textView.isEditable = editable
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.baby?.notes == nil {
            self.textView.text = ""
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        baby?.notes = self.textView.text
    }
    
    func updateInterface() {
        if let text = self.baby?.notes {
            self.textView.text = text
        } else {
            if editable {
                self.textView.text = "EMPTY_NOTE_EDITABLE"
            } else {
                self.textView.text = "EMPTY_NOTE_READ_ONLY"
            }
        }
    }
}
