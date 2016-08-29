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
        guard let entityDescription: NSEntityDescription = NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext) else {
            fatalError("There is no Entity with name \(entityName) in the managed object model")
        }
        return entityDescription
    }
}

open class EntityMapping: Mapping, EntityMappingProtocol {
    open let managedObjectContext: NSManagedObjectContext
    open let entityName: String

    public init(
        destinationClass: NSObject.Type,
        mapping: MappingProtocol,
        managedObjectContext: NSManagedObjectContext
        ) {
        self.entityName = destinationClass.className
        self.managedObjectContext = managedObjectContext
        super.init(destinationClass: destinationClass, idAttributeName: mapping.idAttributeName, attributeMapping: mapping.attributeMapping)
        self.transformers = mapping.transformers
        self.futureConnections = mapping.futureConnections
        self.cherryPickers = mapping.cherryPickers
        self.shouldStoreConditions = mapping.shouldStoreConditions
    }
}
