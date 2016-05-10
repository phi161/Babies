//
//  AdultType+CoreDataProperties.swift
//  Babies
//
//  Created by phi161 on 11/05/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension AdultType {

    @NSManaged var title: String?
    @NSManaged var userDefined: NSNumber?
    @NSManaged var adults: NSSet?

}
