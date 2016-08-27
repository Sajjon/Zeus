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
    func mapping(withJson json: JSON, fromPath path: String, options: Options?) -> Result
    func mapping(withJsonArray jsonArray: [JSON], fromPath path: String, options: Options?) -> Result
    func addResponseDescriptors(fromContext context: MappingContext)
}

internal class ModelMappingManager: ModelMappingManagerProtocol {

    fileprivate var pathToDescriptorMap: Dictionary<String, ResponseDescriptorProtocol> = [:]
    fileprivate let inMemoryModelMapper: InMemoryModelMapperProtocol
    fileprivate let managedObjectMapper: ManagedObjectMapperProtocol

    internal init() {
        let inMemoryStore = InMemoryStore()
        let managedObjectStore = ManagedObjectStore()
        inMemoryModelMapper = InMemoryModelMapper(inMemoryStore: inMemoryStore)
        managedObjectMapper = ManagedObjectMapper(managedObjectStore: managedObjectStore)
    }

    internal func mapping(withJsonArray jsonArray: [JSON], fromPath path: String, options: Options?) -> Result {
        var models: [NSObject] = []
        var error: NSError?
        for json in jsonArray {
            let result = mapping(withJson: json, fromPath: path, options: options)
            guard let model = result.data else {
                if let mappingError = result.error {
                    error = mappingError
                    break
                } else if let mappingEvent = result.mappingEvent {
                    log.info(mappingEvent)
                } else { fatalError("This should not happen") }

                continue
            }
            models.append(model)
        }

        let result: Result
        if let error = error {
            result = Result(error: error)
        } else {
            result = Result(data: models as NSObject?)
        }
        return result
    }

    internal func mapping(withJson json: JSON, fromPath path: String, options: Options?) -> Result {
        guard let descriptor = responseDescriptor(forPath: path) else { return Result(.mappingNoResponseDescriptor) }
        let result = model(fromJson: json, withMapping: descriptor.mapping, options: options)
        return result
    }

    internal func addResponseDescriptors(fromContext context: MappingContext) {
        for descriptor in context.responseDescriptors {
            add(responseDescriptor: descriptor)
        }
    }

    fileprivate var inverseFutureConnectionMap: Dictionary<String, [FutureConnectionProtocol]> = [:]
}

//MARK: Private Methods
private extension ModelMappingManager {

    func add(responseDescriptor descriptor: ResponseDescriptorProtocol) {
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

    func model(fromJson json: JSON, withMapping mapping: MappingProtocol, options: Options?) -> Result {
        let result: Result
        if mapping is EntityMappingProtocol {
            result = managedObjectMapper.model(fromJson: json, withMapping: mapping, options: options)
        } else {
            result = inMemoryModelMapper.model(fromJson: json, withMapping: mapping, options: options)
        }
        return result
    }

    func responseDescriptor(forPath path: String) -> ResponseDescriptorProtocol? {
        let parsedPath = parse(path: path)
        let descriptor = pathToDescriptorMap[parsedPath]
        return descriptor
    }

    func parse(path: String) -> String {
        guard let url = URL(string: path) else { return path }
        let parsedPath: String
        if let lastPathComponent = url.lastPathComponent, let _ = Int(lastPathComponent) {
            parsedPath = url.absoluteString.replacingOccurrences(of: lastPathComponent, with: ":id")
        } else {
            parsedPath = path
        }
        return parsedPath
    }
}

private extension NSManagedObject {
    func update(withJson json: MappedJSON) {
        setValuesForKeys(json)
    }
}

public extension NSManagedObjectContext {
    public func saveToPersistentStore() -> Bool {

        var moc: NSManagedObjectContext! = self

        while moc != nil {
            performAndWait() {
                let newlyInsertedObjects = Array(moc.insertedObjects)
                do {
                    try moc.obtainPermanentIDs(for: newlyInsertedObjects)
                } catch let error {
                    log.error("Failed to obtain permanent ids for objects, error: \(error)")
                }
            }

            performAndWait() {
                do {
                    try moc.save()
                } catch let error {
                    log.error("Failed to save objects, error: \(error)")
                }
            }

            guard moc.parent != nil || moc.persistentStoreCoordinator != nil else {
                log.error("Called saveToPersistentStore on managedObjectContext that has no parentContext or persistentStoreCoordinator, objects are therefore not persisted")
                return false
            }
            
            moc = moc.parent
        }
        
        return true
    }
}

