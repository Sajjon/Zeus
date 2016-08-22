//
//  ModelMapper.swift
//  Zeus
//
//  Created by Cyon Alexander (Ext. Netlight) on 22/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData

typealias JSON = [String: AnyObject]
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
        let mappedJson = map(json: json, withMapping: mapping)
        /* Try to find an existing istance and update it using identity attribute */
        let model: NSManagedObject
        if let existing = existingModel(fromJson: mappedJson, withMapping: mapping) {
            print("Found existing model")
            model = existing
        } else {
            model = NSManagedObject(entity: mapping.entity, insertIntoManagedObjectContext: mapping.managedObjectContext)
        }
        model.update(withJson: mappedJson)
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
        return nil
    }

    private func responseDescriptor(forPath path: String) -> ResponseDescriptorProtocol? {
        let descriptor = pathToDescriptorMap[path]
        return descriptor
    }
}

private extension NSManagedObject {
    func update(withJson json: MappedJSON) {
        setValuesForKeysWithDictionary(json)
    }
}
