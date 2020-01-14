//
//  BabyProvider.swift
//  Babies
//
//  Created by phi on 13/01/2020.
//  Copyright © 2020 phi161. All rights reserved.
//

import Foundation

protocol BabyProvider {
    func babies() -> Set<Baby>
}

struct CoreDataBabyProvider: BabyProvider {
    func babies() -> Set<Baby> {
        return [
            Baby(firstName: "f1", lastName: "l1", existence: .unborn(due: Date()), gender: .girl),
            Baby(firstName: "f2", lastName: "l2", existence: .unborn(due: Date()), gender: .boy),
            Baby(firstName: "f3", lastName: "l3", existence: .born(birthday: Date()), gender: .unspecified)
        ]
    }
}
