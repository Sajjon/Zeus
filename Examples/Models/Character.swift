//
//  Country.swift
//  
//
//  Created by Cyon Alexander (Ext. Netlight) on 19/08/16.
//
//

import Foundation
import CoreData
import Zeus

class ManagedObject: NSManagedObject, Mappable {
    class var entity: NSManagedObject.Type {
        return self
    }
    class var idAttributeName: String { fatalError(mustOverride) }
    class var attributeMapping: AttributeMappingProtocol { fatalError(mustOverride) }
}

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