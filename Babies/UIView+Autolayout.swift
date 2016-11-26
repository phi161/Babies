//
//  UIView+Autolayout.swift
//  Babies
//
//  Created by phi on 26/11/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit

extension UIView {

    /// Pins a views edges to its superview
    /// Visual format taken from http://stackoverflow.com/a/39549290/289501
    ///
    /// - Parameter inset: The (equal) inset from the superview's edges
    func pinEdgesToSuperViewEdges(withInset inset: Float = 0) {
        
        guard let superview = self.superview else {
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false

        let horizontalVisualFormat = "H:|-\(inset)-[subview]-\(inset)-|"
        let verticalVisualFormat = "V:|-\(inset)-[subview]-\(inset)-|"

        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: horizontalVisualFormat, options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: verticalVisualFormat, options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
    }
}
