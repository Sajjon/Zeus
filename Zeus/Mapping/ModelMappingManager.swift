//
//  ModelMapper.swift
//  Zeus
//
//  Created by Cyon Alexander on 22/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData

internal protocol InMemoryStoreProtocol {
    func existingModel(fromJson json: MappedJSON, withMapping mapping: MappingProtocol) -> Any?
    func store(model: Any)
}

internal class InMemoryStore: InMemoryStoreProtocol {
    internal func existingModel(fromJson json: MappedJSON, withMapping mapping: MappingProtocol) -> Any? {
        return nil
    }

    func store(model: Any) {}
}

internal protocol InMemoryModelMapperProtocol{
    func model(fromJson json: JSON, withMapping mapping: MappingProtocol) -> Any?
}

internal protocol ManagedObjectMapperProtocol: InMemoryModelMapperProtocol {}

internal class InMemoryModelMapper: InMemoryModelMapperProtocol {

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
        return nil
    }

    internal func newModel(fromJson json: MappedJSON, withMapping mapping: MappingProtocol) -> Any? {
        return nil
    }

}
private extension InMemoryModelMapper {
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

internal class ManagedObjectMapper: InMemoryModelMapper, ManagedObjectMapperProtocol {
    internal override func existingModel(fromJson json: MappedJSON, withMapping mapping: MappingProtocol) -> Any? {
        guard let entityMapping = mapping as? EntityMappingProtocol else { return nil }
        let existing = existingEntityObject(fromJson: json, withMapping: entityMapping)
        return existing
    }
}

private extension ManagedObjectMapper {
    private func existingEntityObject(fromJson json: MappedJSON, withMapping mapping: EntityMappingProtocol) -> NSManagedObject? {
        let idAttributeName = mapping.idAttributeName
        guard let idAttributeValue = json[idAttributeName] else { return nil }
        let fetchRequest = NSFetchRequest(entityName: mapping.entityName)
        fetchRequest.predicate = NSPredicate(format: "%K == %@", idAttributeName, idAttributeValue)

        var existingModel: NSManagedObject?
        do {
            guard let objects = try mapping.managedObjectContext.executeFetchRequest(fetchRequest) as? [NSManagedObject] else { return nil }
            guard objects.count > 0 else { return nil }
            guard objects.count == 1 else { let msg = "Found multiple objects for identification attribute, this should not happen"; log.warning(msg); fatalError(msg) }
            existingModel = objects.first
        } catch let error {
            log.error("Could not fetch existing objects, error: \(error)")
        }

        return existingModel
    }
}

internal protocol ModelMappingManagerProtocol {
    func mapping(withJson json: JSON, fromPath path: String) -> Result
    func mapping(withJsonArray jsonArray: [JSON], fromPath path: String) -> Result
    func addResponseDescriptors(fromContext context: MappingContext)
}

internal class ModelMappingManager: ModelMappingManagerProtocol {

    private var pathToDescriptorMap: Dictionary<String, ResponseDescriptorProtocol> = [:]
    private let inMemoryModelMapper: InMemoryModelMapperProtocol
    private let managedObjectMapper: ManagedObjectMapperProtocol

    internal init() {
        inMemoryModelMapper = InMemoryModelMapper()
        managedObjectMapper = ManagedObjectMapper()
    }

    internal func mapping(withJsonArray jsonArray: [JSON], fromPath path: String) -> Result {
        var models: [Any] = []
        var error: NSError?
        for json in jsonArray {
            let result = mapping(withJson: json, fromPath: path)
            guard let model = result.data else {
                error = result.error
                break
            }
            models.append(model)
        }

        let result: Result
        if let error = error {
            result = Result(error: error)
        } else {
            result = Result(data: models)
        }
        return result
    }

    internal func mapping(withJson json: JSON, fromPath path: String) -> Result {
        guard let descriptor = responseDescriptor(forPath: path) else { return Result(.MappingNoResponseDescriptor) }
        let result: Result
        if let model = model(fromJson: json, withMapping: descriptor.mapping) {
            result = Result(data: model)
        } else {
            result = Result(.MappingModel)
        }
        return result
    }

    internal func addResponseDescriptors(fromContext context: MappingContext) {
        for descriptor in context.responseDescriptors {
            add(responseDescriptor: descriptor)
        }
    }

    private var inverseFutureConnectionMap: Dictionary<String, [FutureConnectionProtocol]> = [:]
}

//MARK: Private Methods
private extension ModelMappingManager {
    private func add(responseDescriptor descriptor: ResponseDescriptorProtocol) {
        pathToDescriptorMap[descriptor.route.pathMapping] = descriptor
        let mapping = descriptor.mapping
        if let futureConnections = mapping.futureConnections {
            for futureConnection in futureConnections {
                let relationship = futureConnection.relationship
                guard let targetEntityName = relationship.destinationEntity?.name else { continue }
                let existingConnections = inverseFutureConnectionMap[targetEntityName]
                var connectionsForEntity = existingConnections ?? []
                connectionsForEntity.append(futureConnection)
                inverseFutureConnectionMap[targetEntityName] = connectionsForEntity
            }
        }
    }

    private func model(fromJson json: JSON, withMapping mapping: MappingProtocol) -> Any? {
        let model: Any?
        if mapping is EntityMappingProtocol {
            model = managedObjectMapper.model(fromJson: json, withMapping: mapping)
        } else {
            model = inMemoryModelMapper.model(fromJson: json, withMapping: mapping)
        }
        return model
    }

    private func responseDescriptor(forPath path: String) -> ResponseDescriptorProtocol? {
        let parsedPath = parse(path: path)
        let descriptor = pathToDescriptorMap[parsedPath]
        return descriptor
    }

    private func parse(path path: String) -> String {
        guard let url = NSURL(string: path) else { return path }
        let parsedPath: String
        if let lastPathComponent = url.lastPathComponent, _ = Int(lastPathComponent) {
            parsedPath = url.absoluteString.stringByReplacingOccurrencesOfString(lastPathComponent, withString: ":id")
        } else {
            parsedPath = path
        }
        return parsedPath
    }
}

private extension NSManagedObject {
    private func update(withJson json: MappedJSON) {
        setValuesForKeysWithDictionary(json)
    }
}

public extension NSManagedObjectContext {
    public func saveToPersistentStore() -> Bool {

        var moc: NSManagedObjectContext! = self

        while moc != nil {
            performBlockAndWait() {
                let newlyInsertedObjects = Array(moc.insertedObjects)
                do {
                    try moc.obtainPermanentIDsForObjects(newlyInsertedObjects)
                } catch let error {
                    log.error("Failed to obtain permanent ids for objects, error: \(error)")
                }
            }

            performBlockAndWait() {
                do {
                    try moc.save()
                } catch let error {
                    log.error("Failed to save objects, error: \(error)")
                }
            }

            guard moc.parentContext != nil || moc.persistentStoreCoordinator != nil else {
                log.error("Called saveToPersistentStore on managedObjectContext that has no parentContext or persistentStoreCoordinator, objects are therefore not persisted")
                return false
            }
            
            moc = moc.parentContext
        }
        
        return true
    }
}

