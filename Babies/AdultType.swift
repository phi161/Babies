//
//  AdultType.swift
//  Babies
//
//  Created by phi161 on 11/05/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import Foundation
import CoreData


class AdultType: NSManagedObject {
    
    convenience init(title: String, identifier: Int, userDefined: Bool, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("AdultType", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.userDefined = userDefined
        self.title = title
        self.identifier = identifier
    }
    
}
