//
//  ModelMapper.swift
//  Zeus
//
//  Created by Cyon Alexander on 22/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData

internal protocol ModelMapperProtocol {
    func mapping(withJson json: JSON, fromPath path: String) -> Result
    func mapping(withJsonArray jsonArray: [JSON], fromPath path: String) -> Result
    func addResponseDescriptors(fromContext context: MappingContext)
}

internal class ModelMapper: ModelMapperProtocol {

    private var pathToDescriptorMap: Dictionary<String, ResponseDescriptorProtocol> = [:]

    internal func mapping(withJsonArray jsonArray: [JSON], fromPath path: String) -> Result {
        var models: [NSManagedObject] = []
        var error: NSError?
        for json in jsonArray {
            let result = mapping(withJson: json, fromPath: path)
            guard let model = result.data as? NSManagedObject else {
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
private extension ModelMapper {
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

    private func model(fromJson json: JSON, withMapping mapping: MappingProtocol) -> NSManagedObject? {
        let moc = mapping.managedObjectContext
        let mappedJson = map(json: json, withMapping: mapping)
        /* Try to find an existing istance and update it using identity attribute */
        let model: NSManagedObject
        if let existing = existingModel(fromJson: mappedJson, withMapping: mapping) {
            log.verbose("Found existing model")
            model = existing
        } else {
            model = NSManagedObject(entity: mapping.entityDescription, insertIntoManagedObjectContext: moc)
        }
        model.update(withJson: mappedJson)
        makeConnections(withMapping: mapping, forModel: model)
        makeInverseConnections(withMapping: mapping, forModel: model)
        moc.saveToPersistentStore()
        return model
    }

    private func makeConnections(withMapping mapping: MappingProtocol, forModel model: NSManagedObject) {
        guard let futureConnections = mapping.futureConnections else { return }
        make(futureConnections, isInverse: false, withMapping: mapping, forModel: model)
    }

    private func makeInverseConnections(withMapping mapping: MappingProtocol, forModel model: NSManagedObject) {
        guard let inverseConnections = inverseFutureConnectionMap[mapping.entityName] else { return }
        make(inverseConnections, isInverse: true, withMapping: mapping, forModel: model)
    }

    private func make(connections: [FutureConnectionProtocol], isInverse: Bool, withMapping mapping: MappingProtocol, forModel model: NSManagedObject) {
        for futureConnection in connections {
            make(connection: futureConnection, isInverse: isInverse, forModel: model, withMapping: mapping)
        }
    }

    private func make(connection connection: FutureConnectionProtocol, isInverse: Bool, forModel model: NSManagedObject, withMapping mapping: MappingProtocol) {
        let sourceAttribute = isInverse ? connection.targetIdAttributeName : connection.sourceAttributeName
        let targetAttribute = isInverse ? connection.sourceAttributeName : connection.targetIdAttributeName

        guard let
            entityNameFromDestination = connection.relationship.destinationEntity?.name,
            entityNameFromSource = connection.relationship.entity.name,
            sourceAttributeValue = model.valueForKey(sourceAttribute) as? NSObject
            else { return }

        if entityNameFromDestination == entityNameFromSource {
            print("mapping self")
        }

        let targetEntityName = isInverse ? entityNameFromSource : entityNameFromDestination

        let moc = mapping.managedObjectContext
        var models: [NSManagedObject]
        let fetchRequest = NSFetchRequest(entityName: targetEntityName)

        if let array = sourceAttributeValue as? NSArray {
            fetchRequest.predicate = NSPredicate(format: "ANY %K CONTAINS %@", targetAttribute, array)
        }

        do {
            guard let objects = try moc.executeFetchRequest(fetchRequest) as? [NSManagedObject] where objects.count > 0 else { return }
            models = objects
        } catch let error {
            log.error("Failed to perform fetch when making connectiong, error: \(error)")
            fatalError()
        }

        if isInverse {
            guard let idOfObjectToMatch = model.valueForKey(sourceAttribute) as? NSObject else {
                print("idOfObjectToMatch is not nsobject")
                return
            }
            for fetchedModel in models {
                guard let idArray = fetchedModel.valueForKey(targetAttribute) as? [NSObject] where idArray.count > 0 else {
                    continue
                }
                for idArrayObject in idArray {
                    if idArrayObject == idOfObjectToMatch {
                        let set = fetchedModel.mutableSetValueForKey(connection.relationship.name)
                        set.addObject(model)
                    }
                }
            }

        }

        log.info("Found #\(models.count) for connection")
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

    private func existingModel(fromJson json: MappedJSON, withMapping mapping: MappingProtocol) -> NSManagedObject? {
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

    private func responseDescriptor(forPath path: String) -> ResponseDescriptorProtocol? {
        guard let url = NSURL(string: path) else { return nil }
        let parsedPath: String
        if let lastPathComponent = url.lastPathComponent, index = Int(lastPathComponent) {
            parsedPath = url.absoluteString.stringByReplacingOccurrencesOfString(lastPathComponent, withString: ":id")
        } else {
            parsedPath = path
        }
        let descriptor = pathToDescriptorMap[parsedPath]
        return descriptor
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

