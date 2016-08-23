//
//  Country.swift
//  ApiOfIceAndFire
//
//  Created by Alexander Georgii-Hemming Cyon on 20/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData
import Zeus

class Character: ManagedObject {
    @NSManaged var name: String?
    @NSManaged var gender: String?
    @NSManaged var house: House?
    @NSManaged var lordOfHouses: NSSet?

    override class var idAttributeName: String {
        return "name"
    }

    override class var attributeMapping: AttributeMappingProtocol {
        return AttributeMapping(mapping: [
            "name": "name",
            "gender": "gender"
        ])
    }
}