//
//  Adult+CoreDataProperties.swift
//  Babies
//
//  Created by phi161 on 12/05/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Adult {

    @NSManaged var contactIdentifier: String?
    @NSManaged var familyName: String?
    @NSManaged var givenName: String?
    @NSManaged var displayOrder: NSNumber?
    @NSManaged var babies: NSSet?
    @NSManaged var type: AdultType?

}
