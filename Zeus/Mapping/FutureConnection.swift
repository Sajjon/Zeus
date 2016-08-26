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
    case OneToOne
    case OneToMany
    case ManyToOne
    case ManyToMany
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
            destinationEntityName = destinationEntity.name,
            sourceEntityName = relationship.entity.name
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
        let relationshipIsToMany = relationship.toMany
        let inverseRelationshipIsToMany = inverseRelationship.toMany
        let type: RelationshipType
        switch (relationshipIsToMany, inverseRelationshipIsToMany) {
        case (true, true):
            type = .ManyToMany
        case (true, false):
            type = .ManyToOne
        case (false, true):
            type = .OneToMany
        case (false, false):
            type = .OneToOne
        }
        return type
    }
}

public class FutureEntityConnection: FutureEntityConnectionProtocol {

    public let relationship: NSRelationshipDescription
    public let sourceAttributeName: String
    public let destinationAttributeName: String

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