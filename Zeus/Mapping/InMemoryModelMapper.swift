//
//  InMemoryModelMapper.swift
//  Zeus
//
//  Created by Cyon Alexander (Ext. Netlight) on 29/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

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

    override internal func newModel(fromJson json: JSONObject, withMapping mapping: MappingProtocol) -> NSObject? {
        let newModel = mapping.destinationClass.init()
        return newModel
    }
}
