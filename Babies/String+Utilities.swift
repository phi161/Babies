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
    
}
