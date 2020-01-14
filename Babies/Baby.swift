//
//  Baby.swift
//  Babies
//
//  Created by phi on 12/01/2020.
//  Copyright © 2020 phi161. All rights reserved.
//

import Foundation

struct Baby: Hashable {
    var firstName: String
    var lastName: String
    var existence: Existence
    var gender: Gender = .unspecified
}

enum Gender {
    case boy
    case girl
    case unspecified
}

extension Gender: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .boy:
            return "🙋‍♂️"
        case .girl:
            return "🙋‍♀️"
        default:
            return "❓"
        }
    }
}

enum Existence: Hashable {
    case unborn(due: Date)
    case born(birthday: Date)
}

extension Existence: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .born:
            return "born"
        default:
            return "unborn"
        }
    }
}

extension Baby: CustomDebugStringConvertible {
    var debugDescription: String {
        return "\(gender) \(firstName) \(lastName): \(existence)"
    }
}
