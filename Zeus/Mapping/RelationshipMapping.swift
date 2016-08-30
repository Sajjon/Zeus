//
//  RelationshipMapping.swift
//  Zeus
//
//  Created by Cyon Alexander (Ext. Netlight) on 25/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

public protocol RelationshipMappingProtocol {
    var sourceKeyPath: String { get }
    var destinationKeyPath: String { get }
    var mapping: MappingProtocol { get }
}

open class RelationshipMapping: RelationshipMappingProtocol {
    open let sourceKeyPath: String
    open let destinationKeyPath: String
    open let mapping: MappingProtocol

    public init(sourceKeyPath: String, destinationKeyPath: String, mapping: MappingProtocol) {
        self.sourceKeyPath = sourceKeyPath
        self.destinationKeyPath = destinationKeyPath
        self.mapping = mapping
    }
}
