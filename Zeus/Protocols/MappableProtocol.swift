//
//  MappableProtocol.swift
//  Zeus
//
//  Created by Alexander Georgii-Hemming Cyon on 25/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData

public protocol Mappable {
    static var idAttributeName: String{get}
    static var attributeMapping: AttributeMappingProtocol{get}
    static var transformers: [TransformerProtocol]? {get}
    static var cherryPickers: [CherryPickerProtocol]? {get}
    static var shouldStoreModelCondtions: [ShouldStoreModelConditionProtocol]? {get}
    static func futureConnections(forMapping mapping: MappingProtocol) -> [FutureConnectionProtocol]?
    static func mapping(store: DataStoreProtocol) -> MappingProtocol
}

public protocol MappableEntity: Mappable {
    static var entity: NSManagedObject.Type { get }
    static func entityMapping(store: DataStoreProtocol) -> EntityMappingProtocol
}

public extension Mappable {
    static func mapping(store: DataStoreProtocol) -> MappingProtocol {
        let mapping = Mapping(idAttributeName: idAttributeName, attributeMapping: attributeMapping)

        if let list = transformers {
            var dictionary: Dictionary<String, TransformerProtocol> = [:]
            for element in list {
                dictionary[element.key] = element
            }
            mapping.transformers = dictionary
        }

        if let list = futureConnections(forMapping: mapping) {
            var dictionary: Dictionary<String, FutureConnectionProtocol> = [:]
            for element in list {
                dictionary[element.relationship.name] = element
            }
            mapping.futureConnections = dictionary
        }

        if let list = cherryPickers {
            var dictionary: Dictionary<String, CherryPickerProtocol> = [:]
            for element in list {
                dictionary[element.attributeName] = element
            }
            mapping.cherryPickers = dictionary
        }

        if let list = shouldStoreModelCondtions {
            var dictionary: Dictionary<String, ShouldStoreModelConditionProtocol> = [:]
            for element in list {
                dictionary[element.attributeName] = element
            }
            mapping.shouldStoreConditions = dictionary
        }

        return mapping
    }
}

public extension MappableEntity {
    static func entityMapping(store: DataStoreProtocol) -> EntityMappingProtocol {
        let moc = store.persistentStoreManagedObjectContext
        let mapping = self.mapping(store)
        let entityMapping = EntityMapping(mapping: mapping, entityName: entity.className, managedObjectContext: moc)
        return entityMapping
    }
}