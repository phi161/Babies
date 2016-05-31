//
//  Gift.swift
//  Babies
//
//  Created by phi161 on 14/04/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import Foundation
import CoreData


class Gift: NSManagedObject {

    func stringRepresentation() -> String {

        var string: String = ""
        string += self.details ?? "n/a"
        string += "("
        string += String(self.price!) ?? "n/a"
        string += ") "
        
        if self.date != nil {
            string += NSDateFormatter.localizedStringFromDate(self.date!, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        } else {
            string += "n/a"
        }

        return string
        
    }

}
