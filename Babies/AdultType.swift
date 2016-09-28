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
        let entity = NSEntityDescription.entity(forEntityName: "AdultType", in: context)!
        self.init(entity: entity, insertInto: context)
        
        self.userDefined = userDefined as NSNumber?
        self.title = title
        self.identifier = identifier as NSNumber?
    }
    
}
