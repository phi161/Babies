//
//  Event+CoreDataProperties.swift
//  Babies
//
//  Created by phi161 on 14/04/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import Foundation
import CoreData

extension Event {

    @NSManaged var type: NSNumber?
    @NSManaged var date: Date?
    @NSManaged var baby: Baby?

}
