//
//  ManagedObjectStore.swift
//  Zeus
//
//  Created by Alexander Georgii-Hemming Cyon on 26/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData


internal protocol ManagedObjectStoreProtocol: StoreProtocol {
}

internal class ManagedObjectStore: ManagedObjectStoreProtocol {


    internal func existingModel(fromJson json: MappedJSON, withMapping mapping: MappingProtocol) -> Any? {
        guard let entityMapping = mapping as? EntityMappingProtocol else { return nil }
        let existing = existingEntityObject(fromJson: json, withMapping: entityMapping)
        return existing
    }
    func store(model: Any) {}
}

private extension ManagedObjectStore {


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