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
    var idAttributeName: String{get}
    var attributeMapping: AttributeMappingProtocol{get}

    var transformers: Dictionary<String, TransformerProtocol>? {get}
    var futureConnections: [FutureConnectionProtocol]? {get}
    var shouldStoreCondtions: [ShouldStoreModelConditionProtocol]? { get }
    var cherryPickers: [CherryPickerProtocol]? { get }

    func add(cherryPicker picker: CherryPickerProtocol)
    func add(shouldStoreCondition condition: ShouldStoreModelConditionProtocol)
    func add(transformer transformer: TransformerProtocol)
    func add(futureConnection connection: FutureConnectionProtocol)
}

public typealias ShouldStoreModelClosure = (incomingValue: Attribute, maybeCurrentValue: Attribute?) -> Bool
public typealias CherryPickingClosure = (incomingValue: Attribute, maybeCurrentValue: Attribute) -> Attribute

public protocol ShouldStoreModelConditionProtocol {
    var shouldStore: ShouldStoreModelClosure { get }
}

public protocol CherryPickerProtocol {
    var valueToStore: CherryPickingClosure { get }
}

public struct ShouldStoreModelCondition: ShouldStoreModelConditionProtocol {
    public let shouldStore: ShouldStoreModelClosure
    public init(closure: ShouldStoreModelClosure) {
        self.shouldStore = closure
    }
}

public struct CherryPicker: CherryPickerProtocol {
    public let valueToStore: CherryPickingClosure
    public init(closure: CherryPickingClosure) {
        self.valueToStore = closure
    }
}


public class Mapping: MappingProtocol {
    public let idAttributeName: String
    public let attributeMapping: AttributeMappingProtocol
    public var transformers: Dictionary<String, TransformerProtocol>?
    public var futureConnections: [FutureConnectionProtocol]?

    public var shouldStoreCondtions: [ShouldStoreModelConditionProtocol]?
    public var cherryPickers: [CherryPickerProtocol]?

    public init(
        idAttributeName: String,
        attributeMapping: AttributeMappingProtocol
        ) {
        self.idAttributeName = idAttributeName
        self.attributeMapping = attributeMapping
    }

    public func add(transformer transformer: TransformerProtocol) {
        if transformers == nil {
            transformers = [:]
        }
        transformers?[transformer.key] = transformer
    }

    public func add(futureConnection connection: FutureConnectionProtocol) {
        if futureConnections == nil {
            futureConnections = []
        }
        futureConnections?.append(connection)
    }

    public func add(cherryPicker picker: CherryPickerProtocol) {
        if cherryPickers == nil {
            cherryPickers = []
        }
        cherryPickers?.append(picker)
    }

    public func add(shouldStoreCondition condition: ShouldStoreModelConditionProtocol) {
        if shouldStoreCondtions == nil {
            shouldStoreCondtions = []
        }
        shouldStoreCondtions?.append(condition)
    }
}

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

public protocol Mappable {
    static var idAttributeName: String{get}
    static var attributeMapping: AttributeMappingProtocol{get}
    static var transformers: [TransformerProtocol]? {get}
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
        if let transformers = transformers {
            var transformerDictionary: Dictionary<String, TransformerProtocol> = [:]
            for transformer in transformers {
                transformerDictionary[transformer.key] = transformer
            }
            mapping.transformers = transformerDictionary
        }
        if let futureConnections = futureConnections(forMapping: mapping) {
            mapping.futureConnections = futureConnections
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