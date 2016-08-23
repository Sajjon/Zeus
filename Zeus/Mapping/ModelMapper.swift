//
//  ModelMapper.swift
//  Zeus
//
//  Created by Cyon Alexander on 22/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData

typealias JSON = Dictionary<String, NSObject>
typealias MappedJSON = JSON

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
}

//MARK: Private Methods
private extension ModelMapper {
    private func add(responseDescriptor descriptor: ResponseDescriptorProtocol) {
        pathToDescriptorMap[descriptor.route.path] = descriptor
    }

    private func model(fromJson json: JSON, withMapping mapping: MappingProtocol) -> NSManagedObject? {
        let moc = mapping.managedObjectContext
        let mappedJson = map(json: json, withMapping: mapping)
        /* Try to find an existing istance and update it using identity attribute */
        let model: NSManagedObject
        if let existing = existingModel(fromJson: mappedJson, withMapping: mapping) {
            print("Found existing model")
            model = existing
        } else {
            model = NSManagedObject(entity: mapping.entityDescription, insertIntoManagedObjectContext: moc)
        }
        model.update(withJson: mappedJson)
        moc.saveToPersistentStore()
        return model
    }

    private func map(json json: JSON, withMapping mapping: MappingProtocol) -> MappedJSON {
        var mappedJson: MappedJSON = [:]
        for (key, value) in json {
            guard let mappedKey = map(key: key, toAttributeWithMapping: mapping.attributeMapping) else { continue }
            mappedJson[mappedKey] = value
        }
        return mappedJson
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
            guard objects.count == 1 else { fatalError("Found multiple objects for identification attribute, this should not happen") }
            existingModel = objects.first
        } catch let error {
            print("Could not fetch existing objects, error: \(error)")
        }

        return existingModel
    }

    private func responseDescriptor(forPath path: String) -> ResponseDescriptorProtocol? {
        let descriptor = pathToDescriptorMap[path]
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
                    print("Failed to obtain permanent ids for objects, error: \(error)")
                }
            }

            performBlockAndWait() {
                do {
                    try moc.save()
                } catch let error {
                    print("Failed to save objects, error: \(error)")
                }
            }

            guard moc.parentContext != nil || moc.persistentStoreCoordinator != nil else {
                print("Called saveToPersistentStore on managedObjectContext that has no parentContext or persistentStoreCoordinator, objects are therefore not persisted")
                return false
            }

            moc = moc.parentContext
        }

        return true
    }
}

