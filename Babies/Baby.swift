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

    @NSManaged func addAdultsObject(_ value: Adult)
    @NSManaged func removeAdultsObject(_ value: Adult)
    @NSManaged func addGiftsObject(_ value: Gift)
    @NSManaged func removeGiftsObject(_ value: Gift)

    var color: UIColor {
        if let s = self.sex?.intValue {
            switch s {
            case 1:
                return UIColor.cyan
            case 2:
                return UIColor.magenta
            default:
                return UIColor.clear
            }
        } else {
            return UIColor.clear
        }
    }

    var iconDateStringRepresentation: NSAttributedString {
        var dateString = ""
        var imageName = ""
        // Prioritize birthday over due date
        if birthday != nil {
            dateString = DateFormatter.localizedString(from: birthday!, dateStyle: .long, timeStyle: .none)
            imageName = "icon_birthday"
        } else if dueDate != nil {
            dateString = DateFormatter.localizedString(from: dueDate!, dateStyle: .long, timeStyle: .none)
            imageName = "icon_duedate"
        } else {
            return NSAttributedString(string: "")
        }

        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: imageName)
        attachment.bounds = CGRect(x: 0, y: -5, width: (attachment.image?.size.width)!, height: (attachment.image?.size.height)!)
        let imageString = NSAttributedString(attachment: attachment)

        let mutableString = NSMutableAttributedString(attributedString: imageString)
        mutableString.append(NSAttributedString(string: " \(dateString)"))

        return mutableString
    }

    var adultsStringRepresentation: String {
        guard let adults = adultsOrdered() else {
            return ""
        }

        var string = ""
        for adult in adults {
            string += adult.name()
            if adult != adults.last {
                string += "\n"
            }
        }
        return string
    }

    var thumbnailImage: UIImage? {
        guard let imageName = imageName else {
            return nil
        }
        // if image exists return it, or else return nil
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = urls[urls.count-1].appendingPathComponent(imageName)
        guard let imageData = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: imageData)
    }

    func fullName() -> String {
        var string: String = ""
        string += self.givenName ?? ""
        if !string.isEmpty {
            string += " "
        }
        string += self.familyName ?? ""

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

    func giftsTotalPrice() -> NSNumber {
        var totalPrice = 0.0
        if let gifts = giftsOrdered() {
            for gift in gifts {
                if let price = gift.price {
                    totalPrice += price.doubleValue
                }
            }
        }
        return NSNumber(value: totalPrice)
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

        // Due date
        string += "\ndue date: "
        if self.dueDate != nil {
            string += DateFormatter.localizedString(from: self.dueDate! as Date, dateStyle: .short, timeStyle: .short)
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
