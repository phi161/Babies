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

    func stringRepresentation() -> String {

        return "family name: \(self.familyName ?? "empty"), given name: \(self.givenName ?? "empty")\n\(self.birthday)"
    }

}
