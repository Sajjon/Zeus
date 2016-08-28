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

    override internal func newModel(fromJson json: MappedJSON, withMapping mapping: MappingProtocol) -> NSObject? {
        let newModel = mapping.destinationClass.init()
        return newModel
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

    override internal func newModel(fromJson json: MappedJSON, withMapping mapping: MappingProtocol) -> NSObject? {
        guard let entityMapping = mapping as? EntityMappingProtocol else { return nil }
        return newModel(fromJson: json, withEntityMapping: entityMapping)
    }
}

private extension ManagedObjectMapper {
    func newModel(fromJson json: MappedJSON, withEntityMapping mapping: EntityMappingProtocol) -> NSManagedObject? {
        let newModel = NSManagedObject(entity: mapping.entityDescription, insertInto: mapping.managedObjectContext)
        return newModel
    }
}

internal protocol ModelMapperProtocol {
    func model(fromJson json: JSON, withMapping mapping: MappingProtocol, options: Options?) -> Result
    var store: StoreProtocol { get }
}

internal class ModelMapper: ModelMapperProtocol {

    var store: StoreProtocol { fatalError("Must override") }

    internal func model(fromJson json: JSON, withMapping mapping: MappingProtocol, options: Options?) -> Result {
        let mappedJson = map(json: json, withMapping: mapping)
        guard shouldStoreModel(mappedJson, withMapping: mapping) else {
            log.verbose("Not storing model with json: \(json) since it does not fulfill store condition")
            return Result(.skippedDueToCondition)
        }
        let result = storeModel(mappedJson, withMapping: mapping, options: options)
        return result
    }

    internal func shouldStoreModel(_ json: MappedJSON, withMapping mapping: MappingProtocol) -> Bool {
        guard let conditions = mapping.shouldStoreConditions else { return true }

        for (attributeName, attributeValue) in json {
            guard let condition = conditions[attributeName] else { continue }
            let currentValue: Attribute? = currentValueFor(attributeNamed: attributeName, fromJson: json, withMapping: mapping, forClazz: mapping.destinationClass)
            guard incomingAttribute(attributeValue, fullfillsCondition: condition, compareTo: currentValue) else { return false }
        }

        return true
    }

    internal func currentValueFor<T: NSObject>(attributeNamed name: String, fromJson json: MappedJSON, withMapping mapping: MappingProtocol, forClazz clazz: T.Type) -> Attribute? {
        var maybeCurrentValue: Attribute?
        if let existing = store.existingModel(fromJson: json, withMapping: mapping) as? T {
            maybeCurrentValue = existing.value(forKey: name) as? Attribute
        }
        return maybeCurrentValue
    }

    internal func incomingAttribute(_ incomingAttribute: Attribute, fullfillsCondition condition: ShouldStoreModelConditionProtocol, compareTo currentValue: Attribute?) -> Bool {
        let fullfills = condition.shouldStore(incomingAttribute, currentValue)
        return fullfills
    }

    internal func cherryPick(from json: MappedJSON, withMapping mapping: MappingProtocol) -> CherryPickedJSON {
        guard let cherryPickers = mapping.cherryPickers else { return json }
        var cherryPickedValues: CherryPickedJSON = json
        for (attributeName, attributeValue) in json {
            guard let
                cherryPicker = cherryPickers[attributeName],
                let currentValue = currentValueFor(attributeNamed: attributeName, fromJson: json, withMapping: mapping, forClazz: mapping.destinationClass)
            else { continue }
            let cherryPickedValue = cherryPicker.valueToStore(attributeValue, currentValue)
            cherryPickedValues[attributeName] = cherryPickedValue
        }
        return cherryPickedValues
    }

    internal func storeModel(_ json: MappedJSON, withMapping mapping: MappingProtocol, options: Options?) -> Result {
        let jsonPair = split(json: json, withMapping: mapping)
        let relationshipJson = jsonPair.relationship
        let attributesJson = jsonPair.attributes

        var maybeModel: NSObject?
        if let existing = existingModel(fromJson: attributesJson, withMapping: mapping) {
            maybeModel = existing
        } else if let new = newModel(fromJson: attributesJson, withMapping: mapping) {
            maybeModel = new
        }
        guard let model = maybeModel else { return Result(ZeusError.mappingModel) }
        setValuesFor(attributes: attributesJson, inModel: model, withMapping: mapping)

        //TODO: This should be moved up the chain, now save is called for every object if receiving a JSON array... this is not optimal!
        if options?.persistEntities == true && store is ManagedObjectStore, let entityMapping = mapping as? EntityMappingProtocol {
            entityMapping.managedObjectContext.saveToPersistentStore()
        }

        return Result(model)
    }

    internal func setValuesFor(attributes attributesJson: MappedJSON, inModel model: NSObject, withMapping mapping: MappingProtocol) {
        let cherryPicked = cherryPick(from: attributesJson, withMapping: mapping)
        model.setValuesForKeys(cherryPicked)
    }

    internal func split(json: MappedJSON, withMapping mapping: MappingProtocol) -> (relationship: MappedJSON, attributes: MappedJSON) {
        return (relationship: json, attributes: json)
    }

    internal func existingModel(fromJson json: MappedJSON, withMapping mapping: MappingProtocol) -> NSObject? {
        let existing = store.existingModel(fromJson: json, withMapping: mapping)
        return existing
    }

    internal func newModel(fromJson json: MappedJSON, withMapping mapping: MappingProtocol) -> NSObject? {
        fatalError("Must override")
    }
}

private extension ModelMapper {

    func makeConnections(withMapping mapping: MappingProtocol, forModel model: NSManagedObject) {

    }

    func map(json: JSON, withMapping mapping: MappingProtocol) -> MappedJSON {
        var mappedJson: MappedJSON = [:]
        for (key, value) in json {
            guard let mappedKey = map(key: key, toAttributeWithMapping: mapping.attributeMapping) else { continue }
            guard let transformedValue = transform(value: value, forKey: key, withMapping: mapping) else { continue }
            mappedJson[mappedKey] = transformedValue
        }
        return mappedJson
    }

    func transform(value: NSObject, forKey key: String, withMapping mapping: MappingProtocol) -> NSObject? {
        guard let transformers = mapping.transformers, let transformer = transformers[key] else { return value }
        let transformedValue = transformer.transform(value: value)
        return transformedValue
    }

    func map(key: String, toAttributeWithMapping mapping: AttributeMappingProtocol) -> String? {
        var mappedKey: String?
        for (mappingKey, value) in mapping.mapping {
            guard mappingKey == key else { continue }
            mappedKey = value
        }
        return mappedKey
    }
}
