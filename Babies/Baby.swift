//
//  Baby.swift
//  Babies
//
//  Created by phi161 on 14/04/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import Foundation
import CoreData


class Baby: NSManagedObject {
    
    func birthdayString() -> String {
        if let d = self.birthday {
            return NSDateFormatter.localizedStringFromDate(d, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        } else {
            return "n/a"
        }
    }
    
    func sexString() -> String {
        
        if let s = self.sex?.integerValue {
            switch s {
            case 0:
                return "n/a"
            case 1:
                return "boy"
            default:
                return "girl"
            }
        } else {
            return "n/a"
        }
    }

    func stringRepresentation() -> String {

        return "\(self.familyName ?? "n/a"), \(self.givenName ?? "n/a")"
    }

}
