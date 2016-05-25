//
//  Baby.swift
//  Babies
//
//  Created by phi161 on 14/04/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Baby: NSManagedObject {
    
    @NSManaged func addAdultsObject(value:Adult)
    @NSManaged func removeAdultsObject(value:Adult)
    
    var thumbnailImage: UIImage? {
        get {
            if imageName != nil {
                // if image exists return it, or else return nil
                let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
                let url = urls[urls.count-1].URLByAppendingPathComponent(imageName!)
                let imageData = NSData(contentsOfURL: url)
                if let _ = imageData {
                    return UIImage(data: imageData!)
                } else {
                    return nil
                }

            } else {
                return nil
            }
        }
    }
    
    func adultsOrdered() -> [Adult]? {
        if let adultsCount = adults?.count {
            if adultsCount > 0 {
                return adults?.sortedArrayUsingDescriptors([NSSortDescriptor(key: "displayOrder", ascending: true)]) as? [Adult]
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    func birthdayString() -> String {
        if let d = self.birthday {
            return NSDateFormatter.localizedStringFromDate(d, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        } else {
            return "n/a"
        }
    }
    
    func sexString() -> String {
        
        if let s = self.sex?.integerValue {
            switch s {
            case 0:
                return "unknown"
            case 1:
                return "boy"
            default:
                return "girl"
            }
        } else {
            return "n/a"
        }
    }

    func stringRepresentation() -> String {
        
        // Name
        var string: String = ""
        string += self.familyName ?? "n/a"
        string += ", "
        string += self.givenName ?? "n/a"
        
        // Sex
        string += " [\(self.sexString())]"
        
        // Delivery date
        string += "\ndelivery: "
        if self.delivery != nil {
            string += NSDateFormatter.localizedStringFromDate(self.delivery!, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        } else {
            string += "n/a"
        }
        
        // Birthday
        string += "\nbirthday: "
        if self.birthday != nil {
            string += NSDateFormatter.localizedStringFromDate(self.birthday!, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        } else {
            string += "n/a"
        }
        
        // Adults
        string += "\n\n"
        string += "\nadults:\n"
        if let adults = self.adultsOrdered() {
            for adult in adults {
                string += "\(adult.stringRepresentation())\n"
            }
        } else {
            string += "no adults yet"
        }
        
        return string
    }

}
