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
    
    @NSManaged func addAdultsObject(_ value:Adult)
    @NSManaged func removeAdultsObject(_ value:Adult)
    @NSManaged func addGiftsObject(_ value:Gift)
    @NSManaged func removeGiftsObject(_ value:Gift)
    
    var thumbnailImage: UIImage? {
        get {
            if imageName != nil {
                // if image exists return it, or else return nil
                let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let url = urls[urls.count-1].appendingPathComponent(imageName!)
                let imageData = try? Data(contentsOf: url)
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
    
    func fullName() -> String {
        var string: String = ""
        string += self.familyName ?? "n/a"
        string += ", "
        string += self.givenName ?? "n/a"
        return string
    }
    
    func giftsOrdered() -> [Gift]? {
        if let giftsCount = gifts?.count {
            if giftsCount > 0 {
                return gifts?.sortedArray(using: [NSSortDescriptor(key: "date", ascending: true)]) as? [Gift]
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func adultsOrdered() -> [Adult]? {
        if let adultsCount = adults?.count {
            if adultsCount > 0 {
                return adults?.sortedArray(using: [NSSortDescriptor(key: "displayOrder", ascending: true)]) as? [Adult]
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    func birthdayString() -> String {
        if let d = self.birthday {
            return DateFormatter.localizedString(from: d as Date, dateStyle: .short, timeStyle: .short)
        } else {
            return "n/a"
        }
    }
    
    func sexString() -> String {
        
        if let s = self.sex?.intValue {
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
            string += DateFormatter.localizedString(from: self.delivery! as Date, dateStyle: .short, timeStyle: .short)
        } else {
            string += "n/a"
        }
        
        // Birthday
        string += "\nbirthday: "
        if self.birthday != nil {
            string += DateFormatter.localizedString(from: self.birthday! as Date, dateStyle: .short, timeStyle: .short)
        } else {
            string += "n/a"
        }
        
        // Adults
        string += "\n"
        string += "\nadults:\n"
        if let adults = self.adultsOrdered() {
            for adult in adults {
                string += "\(adult.stringRepresentation())\n"
            }
        } else {
            string += "no adults yet"
        }
        
        // Gifts
        string += "\n"
        string += "\nGifts:\n"
        if let gifts = self.giftsOrdered() {
            for gift in gifts {
                string += "\(gift.stringRepresentation())\n"
            }
        } else {
            string += "no gifts yet"
        }
        
        return string
    }

}
