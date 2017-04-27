//
//  String+Utilities.swift
//  Babies
//
//  Created by phi on 26/11/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import Foundation

extension String {
    
    /// Checks if a string is blank (containing whitespaces)
    ///
    /// - Returns: true if the string only contains spaces and/or new lines
    func isBlank() -> Bool {
        let nonBlankText = self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        return nonBlankText.isEmpty
    }
    
    /// Converts a string to a Double with respect to the decimal separator per region ("." or ",")
    var doubleValue: Double {
        let numberFormatter = NumberFormatter()
        numberFormatter.decimalSeparator = "."
        if let result = numberFormatter.number(from: self) {
            return result.doubleValue
        } else {
            numberFormatter.decimalSeparator = ","
            if let result = numberFormatter.number(from: self) {
                return result.doubleValue
            }
        }
        return 0
    }
    
}
