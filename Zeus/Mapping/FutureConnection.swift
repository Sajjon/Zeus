//
//  FutureConnection.swift
//  Zeus
//
//  Created by Alexander Georgii-Hemming Cyon on 24/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData

public protocol FutureConnectionProtocol {
    var relationship: NSRelationshipDescription{get}
    var sourceAttributeName: String{get}
    var targetIdAttributeName: String{get}
}

public class FutureConnection: FutureConnectionProtocol {

    public let relationship: NSRelationshipDescription
    public let sourceAttributeName: String
    public let targetIdAttributeName: String

    public convenience init(relationshipName: String, mapping: MappingProtocol, sourceAttributeName: String, targetIdAttributeName: String) {
        let relationship = mapping.entityDescription.relationshipsByName[relationshipName]!
        self.init(relationship: relationship, sourceAttributeName: sourceAttributeName, targetIdAttributeName: targetIdAttributeName)
    }

    public init(relationship: NSRelationshipDescription, sourceAttributeName: String, targetIdAttributeName: String) {
        self.relationship = relationship
        self.sourceAttributeName = sourceAttributeName
        self.targetIdAttributeName = targetIdAttributeName
    }
}