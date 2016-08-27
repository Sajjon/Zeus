//
//  FutureConnection.swift
//  Zeus
//
//  Created by Alexander Georgii-Hemming Cyon on 24/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData

public enum RelationshipType: Int {
    case oneToOne
    case oneToMany
    case manyToOne
    case manyToMany
}

public protocol FutureConnectionProtocol {
    var connectionName: String { get }
    var sourceAttributeName: String { get }
    var destinationAttributeName: String { get }
}

public protocol FutureEntityConnectionProtocol: FutureConnectionProtocol {
    var relationship: NSRelationshipDescription { get }
}

public extension FutureEntityConnectionProtocol {

    public var connectionName: String {
        return relationship.name
    }

    /**
     Convenience property that returns 'true' relationship within the same relationship.
     */
    var intraMapping: Bool {
        guard let
            destinationEntity = relationship.destinationEntity,
            let destinationEntityName = destinationEntity.name,
            let sourceEntityName = relationship.entity.name
            else { return false }
        let intra = destinationEntityName == sourceEntityName
        return intra
    }

    var inverseRelationship: NSRelationshipDescription {
        guard let inverse = relationship.inverseRelationship else {
            let error = "Relationship \(relationship.name) for entity: \(relationship.entity) should have inverse relationship"
            log.error(error)
            fatalError(error)
        }
        return inverse
    }

    var type: RelationshipType {
        let relationshipIsToMany = relationship.isToMany
        let inverseRelationshipIsToMany = inverseRelationship.isToMany
        let type: RelationshipType
        switch (relationshipIsToMany, inverseRelationshipIsToMany) {
        case (true, true):
            type = .manyToMany
        case (true, false):
            type = .manyToOne
        case (false, true):
            type = .oneToMany
        case (false, false):
            type = .oneToOne
        }
        return type
    }
}

open class FutureEntityConnection: FutureEntityConnectionProtocol {

    open let relationship: NSRelationshipDescription
    open let sourceAttributeName: String
    open let destinationAttributeName: String

    public convenience init(relationshipName: String, entityMapping: EntityMappingProtocol, sourceAttributeName: String, destinationAttributeName: String) {
        let relationship = entityMapping.entityDescription.relationshipsByName[relationshipName]!
        self.init(relationship: relationship, sourceAttributeName: sourceAttributeName, destinationAttributeName: destinationAttributeName)
    }

    public init(relationship: NSRelationshipDescription, sourceAttributeName: String, destinationAttributeName: String) {
        self.relationship = relationship
        self.sourceAttributeName = sourceAttributeName
        self.destinationAttributeName = destinationAttributeName
    }
}
