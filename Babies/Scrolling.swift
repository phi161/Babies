//
//  Scrolling.swift
//  Babies
//
//  Created by phi on 16/10/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import Foundation
import UIKit

/**
 A protocol for handling scrolling when the keyboard appears during text editing
 */
protocol Scrollable {
    var scrollView: UIScrollView { get }
}

extension Scrollable where Self: UIViewController {
    func startObservingKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardDidShow, object: nil, queue: nil) { (notification) in
            self.keyboardDidShow(notification: notification)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: nil) { (notification) in
            self.keyboardWillHide(notification: notification)
        }
    }

    func stopObservingKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func keyboardDidShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets

            guard let tappedView = self.scrollView.hitTest(self.scrollView.panGestureRecognizer.location(in: self.scrollView), with: nil) else {
                return
            }

            if tappedView is UITextView || tappedView is UITextField {
                self.scrollView.scrollRectToVisible(self.scrollView.convert(tappedView.bounds, from: tappedView), animated: true)
            }
        }
    }

    func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
}
