//
//  Mapping.swift
//  Zeus
//
//  Created by Cyon Alexander on 22/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

public protocol MappingProtocol {
    var destinationClass: NSObject.Type { get }
    var idAttributeName: String { get }
    var attributeMapping: AttributeMappingProtocol { get }

    var relationships: Dictionary<String, RelationshipMappingProtocol>? { get }
    var transformers: Dictionary<String, TransformerProtocol>? { get }
    var futureConnections: Dictionary<String, FutureConnectionProtocol>? { get }
    var shouldStoreConditions: Dictionary<String, ShouldStoreModelConditionProtocol>? { get }
    var cherryPickers: Dictionary<String, CherryPickerProtocol>? { get }

    func add(relationship relationship: RelationshipMappingProtocol)
    func add(cherryPicker picker: CherryPickerProtocol)
    func add(shouldStoreCondition condition: ShouldStoreModelConditionProtocol)
    func add(transformer: TransformerProtocol)
    func add(futureConnection connection: FutureConnectionProtocol)

    func relationship(forKey key: String) -> RelationshipMappingProtocol?
    func shouldStoreCondition(forAttributeName attributeName: String) -> ShouldStoreModelConditionProtocol?
    func cherryPicker(forAttributeName attributeName: String) -> CherryPickerProtocol?
    func transformer(forKey key: String) -> TransformerProtocol?
    func futureConnection(forRelationshipName relationshipName: String) -> FutureConnectionProtocol?
}

open class Mapping: MappingProtocol {
    open let destinationClass: NSObject.Type
    open let idAttributeName: String
    open let attributeMapping: AttributeMappingProtocol

    open var relationships: Dictionary<String, RelationshipMappingProtocol>?

    open var transformers: Dictionary<String, TransformerProtocol>?
    open var futureConnections: Dictionary<String, FutureConnectionProtocol>?
    open var shouldStoreConditions: Dictionary<String, ShouldStoreModelConditionProtocol>?
    open var cherryPickers: Dictionary<String, CherryPickerProtocol>?

    public init(
        destinationClass: NSObject.Type,
        idAttributeName: String,
        attributeMapping: AttributeMappingProtocol
        ) {
        self.destinationClass = destinationClass
        self.idAttributeName = idAttributeName
        self.attributeMapping = attributeMapping
    }

    open func add(relationship relationship: RelationshipMappingProtocol) {
        if relationships == nil {
            relationships = [:]
        }
        relationships?[relationship.sourceKeyPath] = relationship
    }

    open func add(transformer: TransformerProtocol) {
        if transformers == nil {
            transformers = [:]
        }
        transformers?[transformer.key] = transformer
    }

    open func add(futureConnection connection: FutureConnectionProtocol) {
        if futureConnections == nil {
            futureConnections = [:]
        }
        futureConnections?[connection.connectionName] = connection
    }

    open func add(cherryPicker picker: CherryPickerProtocol) {
        if cherryPickers == nil {
            cherryPickers = [:]
        }
        cherryPickers?[picker.attributeName] = picker
    }

    open func add(shouldStoreCondition condition: ShouldStoreModelConditionProtocol) {
        if shouldStoreConditions == nil {
            shouldStoreConditions = [:]
        }
        shouldStoreConditions?[condition.attributeName] = condition
    }

    open func relationship(forKey key: String) -> RelationshipMappingProtocol? {
        let relationship = relationships?[key]
        return relationship
    }

    open func shouldStoreCondition(forAttributeName attributeName: String) -> ShouldStoreModelConditionProtocol? {
        let condition = shouldStoreConditions?[attributeName]
        return condition
    }

    open func cherryPicker(forAttributeName attributeName: String) -> CherryPickerProtocol? {
        let picker = cherryPickers?[attributeName]
        return picker
    }

    open func transformer(forKey key: String) -> TransformerProtocol? {
        let transformer = transformers?[key]
        return transformer
    }

    open func futureConnection(forRelationshipName relationshipName: String) -> FutureConnectionProtocol? {
        let connection = futureConnections?[relationshipName]
        return connection
    }
}
