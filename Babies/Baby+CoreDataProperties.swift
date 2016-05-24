//
//  Baby+CoreDataProperties.swift
//  Babies
//
//  Created by phi161 on 24/05/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import Foundation
import CoreData

extension Baby {

    @NSManaged var birthday: NSDate?
    @NSManaged var delivery: NSDate?
    @NSManaged var familyName: String?
    @NSManaged var givenName: String?
    @NSManaged var notes: String?
    @NSManaged var sex: NSNumber?
    @NSManaged var imageName: String?
    @NSManaged var adults: NSSet?
    @NSManaged var events: Event?
    @NSManaged var gifts: NSSet?

}
