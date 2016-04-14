//
//  Adult+CoreDataProperties.swift
//  Babies
//
//  Created by phi161 on 14/04/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import Foundation
import CoreData

extension Adult {

    @NSManaged var givenName: String?
    @NSManaged var contactIdentifier: String?
    @NSManaged var familyName: String?
    @NSManaged var type: NSNumber?
    @NSManaged var babies: NSSet?

}
