//
//  AttributeMapping.swift
//  Zeus
//
//  Created by Cyon Alexander (Ext. Netlight) on 22/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

public protocol AttributeMappingProtocol {
    var mapping: JSONMapping{get}
}

public struct AttributeMapping: AttributeMappingProtocol {
    public let mapping: JSONMapping
    public init(mapping: JSONMapping) {
        self.mapping = mapping
    }
}