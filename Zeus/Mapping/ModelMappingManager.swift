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
    func mapping(withJsonArray jsonArray: [JSON], fromPath path: APIPathProtocol, options: Options?) -> Result
    func mapping(withJsonOrArray json: JSON, fromPath path: APIPathProtocol, options: Options?) -> Result
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

    internal func mapping(withJsonArray jsonArray: [JSON], fromPath path: APIPathProtocol, options: Options?) -> Result {
        return mapping(withJsonArray: jsonArray, fromPath: path, options: options, specifiedMapping: nil)
    }

    internal func mapping(withJsonArray jsonArray: [JSON], fromPath path: APIPathProtocol, options: Options?, specifiedMapping: MappingProtocol?) -> Result {
        var models: [NSObject] = []
        var error: NSError?
        for json in jsonArray {
            let result = mapping(withJson: json, fromPath: path, options: options, specifiedMapping: specifiedMapping)
            switch result {
            case .success(let model):
                models.append(model)
            case .failure(let mappingError):
                guard mappingError.isEvent else {
                    error = mappingError.error
                    break
                }
                log.info(error)
            }
        }

        let result: Result
        if let error = error {
            result = Result(error)
        } else {
            result = Result(NSArray(array: models))
        }
        return result
    }

    internal func mapping(withJsonOrArray json: JSON, fromPath path: APIPathProtocol, options: Options?) -> Result {
        return mapping(withJsonOrArray: json, fromPath: path, options: options, specifiedMapping: nil)
    }

    internal func mapping(withJsonOrArray json: JSON, fromPath path: APIPathProtocol, options: Options?, specifiedMapping: MappingProtocol?) -> Result {
        guard let descriptor = responseDescriptor(forPath: path) else { let error = ZeusError.mappingNoResponseDescriptor; log.error(error.errorMessage); return Result(error) }

        let result: Result
        if let jsonKeyPath = descriptor.jsonKeyPath {
            result = mapping(forJson: json, at: jsonKeyPath, fromAPIPath: path, options: options, specifiedMapping: specifiedMapping)
        } else {
            result = mapping(withJson: json, fromPath: path, options: options, specifiedMapping: specifiedMapping)
        }
        return result
    }

    internal func addResponseDescriptors(fromContext context: MappingContext) {
        for descriptor in context.responseDescriptors {
            add(responseDescriptor: descriptor)
        }
    }

//    fileprivate var inverseFutureConnectionMap: Dictionary<String, [FutureConnectionProtocol]> = [:]
}

//MARK: Private Methods
private extension ModelMappingManager {

    func mapping(withJson json: JSON, fromPath path: APIPathProtocol, options: Options?, specifiedMapping: MappingProtocol?) -> Result {
        let theMappingUsed: MappingProtocol
        if let didSpecifyMapping = specifiedMapping {
            theMappingUsed = didSpecifyMapping
        } else {
            guard let descriptorX = responseDescriptor(forPath: path) else { let error = ZeusError.mappingNoResponseDescriptor; log.error(error.errorMessage); return Result(error) }
            theMappingUsed = descriptorX.mapping
        }

        let result = model(fromJson: json, withMapping: theMappingUsed, options: options)
        switch result {
        case .success(let model):
            setRelationshipValuesFor(model: model, json: json, mapping: theMappingUsed, fromAPIPath: path, options: options)
        default:
            break
        }
        return result
    }

    func setRelationshipValuesFor(model: NSObject, json: JSON, mapping theMapping: MappingProtocol, fromAPIPath path: APIPathProtocol, options: Options?) {
        guard let relationships = theMapping.relationships else { return }
        for (_, relationship) in relationships {
            let source = relationship.sourceKeyPath
            let destination = relationship.destinationKeyPath
            let relationshipMapping = mapping(forJson: json, at: source, fromAPIPath: path, options: options, specifiedMapping: relationship.mapping)
            switch relationshipMapping {
            case .success(let relationshipModel):
                print("setting value for relationship")
                if let sourceEntityMapping = theMapping as? EntityMappingProtocol {
                    guard let managedObject = model as? NSManagedObject else { log.error("not managed obj"); continue }
                    let sourceEntityDescription = sourceEntityMapping.entityDescription
                    let relationshipsByName = sourceEntityDescription.relationshipsByName
                    guard let coreDataRelationship: NSRelationshipDescription = relationshipsByName[destination] else { log.error("no rel. by name"); continue }
                    guard let inversedRelationship = coreDataRelationship.inverseRelationship else { log.error("no inverse"); continue }
                    let type: RelationshipType
                    switch (coreDataRelationship.isToMany, inversedRelationship.isToMany) {
                    case (true, true):
                        type = RelationshipType.manyToMany
                    case (false, true):
                        type = RelationshipType.oneToMany
                    case (false, false):
                        type = RelationshipType.oneToOne
                    case (true, false):
                        type = RelationshipType.manyToOne
                    }

                    switch type {
                    case .oneToOne:
                        print("one to one")
                        break
                    case .oneToMany:
                        print("one to many")
                        break
                    case .manyToOne:
                        print("many to one")
                        break
                    case .manyToMany:
                        print("many to many")
                        break
                    }

                    if coreDataRelationship.isToMany {
                        guard let arrayOfObjects = relationshipModel as? [NSManagedObject] else { log.error("not mo array"); continue }
                        if coreDataRelationship.isOrdered {
                            let objectsAsOrderedSet = NSOrderedSet(array: arrayOfObjects)
                            managedObject.setValue(objectsAsOrderedSet, forKey: destination)
                        } else {
                            let objectsAsSet = NSSet(array: arrayOfObjects)
                            managedObject.setValue(objectsAsSet, forKey: destination)
                        }
                    } else {
                        managedObject.setValue(relationshipModel, forKey: destination)
                    }

                } else {
                    model.setValue(relationshipModel, forKey: destination)
                }
            case .failure(let error):
                print("fail, error: \(error)")
                continue
            }
        }
    }

    func mapping(forJson json: JSON, at keyPath: String, fromAPIPath apiPath: APIPathProtocol, options: Options?, specifiedMapping: MappingProtocol?) -> Result {
        guard
            let subJson = json.valueFor(nestedKey: keyPath)
            else {
                return Result(.parsingJSON)
        }

        if let rawJsonArray = subJson as? [RawJSON] {
            let jsonArray: [JSON] = rawJsonArray.map { return JSON($0) }
            return mapping(withJsonArray: jsonArray, fromPath: apiPath, options: options, specifiedMapping: specifiedMapping)
        } else if let rawJson = subJson as? RawJSON {
            return mapping(withJson: JSON(rawJson), fromPath: apiPath, options: options, specifiedMapping: specifiedMapping)
        }

        return Result(.parsingJSON)
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

    func responseDescriptor(forPath path: APIPathProtocol) -> ResponseDescriptorProtocol? {
        let descriptor = pathToDescriptorMap[path.mapping]
        return descriptor
    }

    func add(responseDescriptor descriptor: ResponseDescriptorProtocol) {
        pathToDescriptorMap[descriptor.apiPath.mapping] = descriptor
        //        let mapping = descriptor.mapping
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
}

private extension NSManagedObject {
    func update(withJson json: MappedJSON) {
        setValuesForKeys(json.map)
    }
}

public extension NSManagedObjectContext {
    @discardableResult
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

