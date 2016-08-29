//
//  InMemoryStore.swift
//  Zeus
//
//  Created by Alexander Georgii-Hemming Cyon on 26/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

internal protocol InMemoryStoreProtocol: StoreProtocol {}

internal class InMemoryStore: InMemoryStoreProtocol {
    internal func existingModel(fromJson json: MappedJSON, withMapping mapping: MappingProtocol) -> NSObject? {
        return nil
    }

    func store(_ model: NSObject) {}
}
