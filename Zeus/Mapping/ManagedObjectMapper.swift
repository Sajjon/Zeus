//
//  ManagedObjectMapper.swift
//  Zeus
//
//  Created by Cyon Alexander (Ext. Netlight) on 29/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData

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
        let new = newModel(fromJson: json, withEntityMapping: entityMapping)
        return new
    }
}

private extension ManagedObjectMapper {
    func newModel(fromJson json: MappedJSON, withEntityMapping mapping: EntityMappingProtocol) -> NSManagedObject? {
        let newModel = NSManagedObject(entity: mapping.entityDescription, insertInto: mapping.managedObjectContext)
        return newModel
    }
}
