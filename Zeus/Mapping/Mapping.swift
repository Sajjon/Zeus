//
//  Mapping.swift
//  Zeus
//
//  Created by Cyon Alexander on 22/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData

public protocol MappingProtocol {
    var managedObjectContext: NSManagedObjectContext{get}
    var entityName: String {get}
    var idAttributeName: String{get}
    var attributeMapping: AttributeMappingProtocol{get}
}

public extension MappingProtocol {
    var entityDescription: NSEntityDescription {
        guard let entityDescription: NSEntityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedObjectContext) else {
            fatalError("There is no Entity with name \(entityName) in the managed object model")
        }
        return entityDescription
    }
}

public struct Mapping: MappingProtocol {
    public let managedObjectContext: NSManagedObjectContext
    public let entityName: String
    public let idAttributeName: String
    public let attributeMapping: AttributeMappingProtocol

    public init(
        entityName: String,
        managedObjectContext: NSManagedObjectContext,
        idAttributeName: String,
        attributeMapping: AttributeMappingProtocol
        ) {
        self.entityName = entityName
        self.managedObjectContext = managedObjectContext
        self.idAttributeName = idAttributeName
        self.attributeMapping = attributeMapping
    }
}

public protocol Mappable {
    static var entity: NSManagedObject.Type{get}
    static var idAttributeName: String{get}
    static var attributeMapping: AttributeMappingProtocol{get}
    static func mapping(store: DataStoreProtocol) -> MappingProtocol
}

public extension Mappable {
    static func mapping(store: DataStoreProtocol) -> MappingProtocol {
        let moc = store.persistentStoreManagedObjectContext
        let mapping = Mapping(entityName: entity.className, managedObjectContext: moc, idAttributeName: idAttributeName, attributeMapping: attributeMapping)
        return mapping
    }
}