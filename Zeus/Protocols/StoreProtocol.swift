//
//  StoreProtocol.swift
//  Zeus
//
//  Created by Alexander Georgii-Hemming Cyon on 26/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

internal protocol StoreProtocol {
    func existingModel(fromJson json: MappedJSON, withMapping mapping: MappingProtocol) -> Any?
    func store(model: Any)
}