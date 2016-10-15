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
        string += " ("
        string += String(describing: self.price!) 
        string += ") "
        
        if self.date != nil {
            string += DateFormatter.localizedString(from: self.date! as Date, dateStyle: .medium, timeStyle: .none)
        } else {
            string += "n/a"
        }

        return string
    }
    
    func detailsString() -> String {
        if let details = self.details {
            return details
        } else {
            return "n/a"
        }
    }

    func priceWithCurrency() -> String {
        let currencySymbol = Locale.current.currencySymbol ?? "€"

        if let price = self.price {
            return "\(currencySymbol)\(price)"
        } else {
            return "\(currencySymbol)0"
        }
    }
}
