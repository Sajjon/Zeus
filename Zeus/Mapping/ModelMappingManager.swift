//
//  ModelMapper.swift
//  Zeus
//
//  Created by Cyon Alexander on 22/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData


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
        let inMemoryStore = InMemoryStore()
        let managedObjectStore = ManagedObjectStore()
        inMemoryModelMapper = InMemoryModelMapper(inMemoryStore: inMemoryStore)
        managedObjectMapper = ManagedObjectMapper(managedObjectStore: managedObjectStore)
    }

    internal func mapping(withJsonArray jsonArray: [JSON], fromPath path: String) -> Result {
        var models: [NSObject] = []
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
//        if let futureConnections = mapping.futureConnections {
//            for (_, futureConnection) in futureConnections {
//                let relationship = futureConnection.relationship
//                guard let targetEntityName = relationship.destinationEntity?.name else { continue }
//                let existingConnections = inverseFutureConnectionMap[targetEntityName]
//                var connectionsForEntity = existingConnections ?? []
//                connectionsForEntity.append(futureConnection)
//                inverseFutureConnectionMap[targetEntityName] = connectionsForEntity
//            }
//        }
    }

    private func model(fromJson json: JSON, withMapping mapping: MappingProtocol) -> NSObject? {
        let model: NSObject?
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

