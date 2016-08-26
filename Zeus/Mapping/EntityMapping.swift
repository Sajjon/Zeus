//
//  EntityMapping.swift
//  Zeus
//
//  Created by Alexander Georgii-Hemming Cyon on 25/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData

public protocol EntityMappingProtocol: MappingProtocol {
    var managedObjectContext: NSManagedObjectContext{get}
    var entityName: String {get}
}

public extension EntityMappingProtocol {
    var entityDescription: NSEntityDescription {
        guard let entityDescription: NSEntityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedObjectContext) else {
            fatalError("There is no Entity with name \(entityName) in the managed object model")
        }
        return entityDescription
    }
}

public class EntityMapping: Mapping, EntityMappingProtocol {
    public let managedObjectContext: NSManagedObjectContext
    public let entityName: String

    public init(
        entityName: String,
        managedObjectContext: NSManagedObjectContext,
        idAttributeName: String,
        attributeMapping: AttributeMappingProtocol
        ) {
        self.entityName = entityName
        self.managedObjectContext = managedObjectContext
        super.init(idAttributeName: idAttributeName, attributeMapping: attributeMapping)
    }

    public init(
        mapping: MappingProtocol,
        entityName: String,
        managedObjectContext: NSManagedObjectContext
        ) {
        self.entityName = entityName
        self.managedObjectContext = managedObjectContext
        super.init(idAttributeName: mapping.idAttributeName, attributeMapping: mapping.attributeMapping)
        self.transformers = mapping.transformers
        self.futureConnections = mapping.futureConnections
    }
}