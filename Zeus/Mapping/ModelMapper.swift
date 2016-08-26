//
//  ModelMapper.swift
//  Zeus
//
//  Created by Alexander Georgii-Hemming Cyon on 26/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData


internal protocol InMemoryModelMapperProtocol: ModelMapperProtocol {
    var inMemoryStore: InMemoryStore { get }
}

internal class InMemoryModelMapper: ModelMapper, InMemoryModelMapperProtocol {
    internal let inMemoryStore: InMemoryStore
    internal init(inMemoryStore: InMemoryStore) {
        self.inMemoryStore = inMemoryStore
    }

    override var store: StoreProtocol {
        return inMemoryStore
    }
}

internal protocol ManagedObjectMapperProtocol: ModelMapperProtocol {
    var managedObjectStore: ManagedObjectStore { get }
}

internal class ManagedObjectMapper: ModelMapper, ManagedObjectMapperProtocol {
    internal let managedObjectStore: ManagedObjectStore
    internal init(managedObjectStore: ManagedObjectStore) {
        self.managedObjectStore = managedObjectStore
    }

    override var store: StoreProtocol {
        return managedObjectStore
    }
}

internal protocol ModelMapperProtocol {
    func model(fromJson json: JSON, withMapping mapping: MappingProtocol) -> Any?
    var store: StoreProtocol { get }
}

internal class ModelMapper: ModelMapperProtocol {

    var store: StoreProtocol { fatalError("Must override") }

    internal func model(fromJson json: JSON, withMapping mapping: MappingProtocol) -> Any? {
        let mappedJson = map(json: json, withMapping: mapping)
        let jsonPair = split(json: mappedJson, withMapping: mapping)
        let relationshipJson = jsonPair.relationship
        let attributesJson = jsonPair.attributes

        let maybeModel: Any?
        if let existing = existingModel(fromJson: attributesJson, withMapping: mapping) {
            maybeModel = existing
        } else {
            maybeModel = newModel(fromJson: attributesJson, withMapping: mapping)
        }
        guard let model = maybeModel else { return nil }
        update(attributes: attributesJson, inModel: model, withMapping: mapping)
        return model

        //        let moc = mapping.managedObjectContext
        //        /* Try to find an existing istance and update it using identity attribute */
        //        let model: NSManagedObject
        //        if let existing = existingEntityObject(fromJson: mappedJson, withMapping: mapping) {
        //            log.verbose("Found existing model")
        //            model = existing
        //        } else {
        //            model = NSManagedObject(entity: mapping.entityDescription, insertIntoManagedObjectContext: moc)
        //        }
        //        model.update(withJson: mappedJson)
        //        makeConnections(withMapping: mapping, forModel: model)
        //        //        makeInverseConnections(withMapping: mapping, forModel: model)
        //        moc.saveToPersistentStore()
    }

    internal func update(attributes attributesJson: MappedJSON, inModel model: Any, withMapping mapping: MappingProtocol) {

    }

    internal func split(json json: MappedJSON, withMapping mapping: MappingProtocol) -> (relationship: MappedJSON, attributes: MappedJSON) {
        return (relationship: json, attributes: json)
    }

    internal func existingModel(fromJson json: MappedJSON, withMapping mapping: MappingProtocol) -> Any? {
        let existing = store.existingModel(fromJson: json, withMapping: mapping)
        return existing
    }

    internal func newModel(fromJson json: MappedJSON, withMapping mapping: MappingProtocol) -> Any? {
        //        if let conditions = mapping.shouldStoreConditions, condition = conditions[] {
        //
        //        }
        return nil
    }
}

private extension ModelMapper {

    private func makeConnections(withMapping mapping: MappingProtocol, forModel model: NSManagedObject) {

    }

    private func map(json json: JSON, withMapping mapping: MappingProtocol) -> MappedJSON {
        var mappedJson: MappedJSON = [:]
        for (key, value) in json {
            guard let mappedKey = map(key: key, toAttributeWithMapping: mapping.attributeMapping) else { continue }
            guard let transformedValue = transform(value: value, forKey: key, withMapping: mapping) else { continue }
            mappedJson[mappedKey] = transformedValue
        }
        return mappedJson
    }

    private func transform(value value: NSObject, forKey key: String, withMapping mapping: MappingProtocol) -> NSObject? {
        guard let transformers = mapping.transformers, transformer = transformers[key] else { return value }
        let transformedValue = transformer.transform(value: value)
        return transformedValue
    }

    private func map(key key: String, toAttributeWithMapping mapping: AttributeMappingProtocol) -> String? {
        var mappedKey: String?
        for (mappingKey, value) in mapping.mapping {
            guard mappingKey == key else { continue }
            mappedKey = value
        }
        return mappedKey
    }
}
