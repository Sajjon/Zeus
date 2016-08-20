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

class Country: ManagedObject {
    @NSManaged var capital: String
    @NSManaged var name: String

    override class var idAttributeName: String {
        return "name"
    }

    override class var attributeMapping: AttributeMappingProtocol {
        return AttributeMapping(mapping: [
            "name": "name",
            "capital": "capital",
        ])
    }
}