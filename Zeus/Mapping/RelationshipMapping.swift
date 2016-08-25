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