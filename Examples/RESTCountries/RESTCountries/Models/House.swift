//
//  House.swift
//  RESTCountries
//
//  Created by Alexander Georgii-Hemming Cyon on 20/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData
import Zeus

class House: ManagedObject {
    @NSManaged var name: String?
    @NSManaged var words: String?
    @NSManaged var region: String?
    @NSManaged var coatOfArms: String?
    @NSManaged var members: NSSet?
    @NSManaged var currentLord: Character?

    override class var idAttributeName: String {
        return "name"
    }

    override class var attributeMapping: AttributeMappingProtocol {
        return AttributeMapping(mapping: [
            "name": "name",
            "words": "words",
            "region": "region",
            "coatOfArms": "coatOfArms"
            ])
    }
}