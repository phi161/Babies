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

// Insert code here to add functionality to your managed object subclass
    func stringRepresentation() -> String {
        return "family name: \(self.familyName), given name: \(self.givenName)\n\(self.birthday)"
    }

}
