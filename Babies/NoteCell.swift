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
            textView.isEditable = editable
            textView.isScrollEnabled = editable
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if baby?.notes == nil {
            textView.text = ""
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        baby?.notes = textView.text
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isBlank() {
            baby?.notes = nil
        }
    }

    func updateInterface() {
        if let text = baby?.notes, !text.isBlank() {
            textView.text = text
        } else {
            if editable {
                textView.text = "EMPTY_NOTE_EDITABLE"
            } else {
                textView.text = "EMPTY_NOTE_READ_ONLY"
            }
        }
    }
}
