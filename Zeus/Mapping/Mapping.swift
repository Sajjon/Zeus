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
    var transformers: Dictionary<String, TransformerProtocol>? {get}
    func add(transformer transformer: TransformerProtocol)
}


public protocol TransformerProtocol {
    var transformation: (NSObject?) -> NSObject? {get}
    var key: String {get}
}

internal extension TransformerProtocol {
    func transform(value value: NSObject) -> NSObject? {
        if let array = value as? [NSObject] {
            return transform(array: array)
        }
        let transformed = transformation(value)
        return transformed
    }

    func transform(array arrayToTranform: [NSObject]) -> NSArray? {
        var transformedArray: [NSObject] = []
        for value in arrayToTranform {
            guard let transformed = transformation(value) else { continue }
            transformedArray.append(transformed)
        }
        return transformedArray
    }
}

public class Transformer: TransformerProtocol {
    public let transformation: (NSObject?) -> NSObject?
    public let key: String
    public init(key: String, transformation: (NSObject?) -> NSObject?) {
        self.key = key
        self.transformation = transformation
    }
}

public extension MappingProtocol {
    var entityDescription: NSEntityDescription {
        guard let entityDescription: NSEntityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedObjectContext) else {
            fatalError("There is no Entity with name \(entityName) in the managed object model")
        }
        return entityDescription
    }
}

public class Mapping: MappingProtocol {
    public let managedObjectContext: NSManagedObjectContext
    public let entityName: String
    public let idAttributeName: String
    public let attributeMapping: AttributeMappingProtocol
    public var transformers: Dictionary<String, TransformerProtocol>?

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

    public func add(transformer transformer: TransformerProtocol) {
        if transformers == nil {
            transformers = [:]
        }
        transformers![transformer.key] = transformer
    }
}

public protocol Mappable {
    static var entity: NSManagedObject.Type{get}
    static var idAttributeName: String{get}
    static var attributeMapping: AttributeMappingProtocol{get}
    static var transformers: [TransformerProtocol]? {get}
    static func mapping(store: DataStoreProtocol) -> MappingProtocol
}

public extension Mappable {
    static func mapping(store: DataStoreProtocol) -> MappingProtocol {
        let moc = store.persistentStoreManagedObjectContext
        let mapping = Mapping(entityName: entity.className, managedObjectContext: moc, idAttributeName: idAttributeName, attributeMapping: attributeMapping)
        if let transformers = transformers {
            var transformerDictionary: Dictionary<String, TransformerProtocol> = [:]
            for transformer in transformers {
                transformerDictionary[transformer.key] = transformer
            }
            mapping.transformers = transformerDictionary
        }
        return mapping
    }
}