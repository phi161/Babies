//
//  Adult.swift
//  Babies
//
//  Created by phi161 on 14/04/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import Foundation
import CoreData


class Adult: NSManagedObject {

    @NSManaged func addBabiesObject(value:Baby)
    @NSManaged func removeBabiesObject(value:Baby)
    
    func name() -> String {
        var string: String = ""
        string += self.givenName ?? ""
        string += " "
        string += self.familyName ?? ""
        return string
    }

    func stringRepresentation() -> String {

        // Name
        var string: String = ""
        string += self.familyName ?? "n/a"
        string += ", "
        string += self.givenName ?? "n/a"
        
        // Type
        guard let _ = self.type, title = self.type?.title else {
            string += " (no type)"
            return string
        }
        
        string += " (\(title))"

        return string

    }
    
}
