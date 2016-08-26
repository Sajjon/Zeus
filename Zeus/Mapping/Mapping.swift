//
//  Mapping.swift
//  Zeus
//
//  Created by Cyon Alexander on 22/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

public protocol MappingProtocol {
    var idAttributeName: String { get }
    var attributeMapping: AttributeMappingProtocol { get }

    var transformers: Dictionary<String, TransformerProtocol>? { get }
    var futureConnections: Dictionary<String, FutureConnectionProtocol>? { get }
    var shouldStoreConditions: Dictionary<String, ShouldStoreModelConditionProtocol>? { get }
    var cherryPickers: Dictionary<String, CherryPickerProtocol>? { get }

    func add(cherryPicker picker: CherryPickerProtocol)
    func add(shouldStoreCondition condition: ShouldStoreModelConditionProtocol)
    func add(transformer transformer: TransformerProtocol)
    func add(futureConnection connection: FutureConnectionProtocol)

    func shouldStoreCondition(forAttributeName attributeName: String) -> ShouldStoreModelConditionProtocol?
    func cherryPicker(forAttributeName attributeName: String) -> CherryPickerProtocol?
    func transformer(forKey key: String) -> TransformerProtocol?
    func futureConnection(forRelationshipName relationshipName: String) -> FutureConnectionProtocol?
}

public class Mapping: MappingProtocol {

    public let idAttributeName: String
    public let attributeMapping: AttributeMappingProtocol

    public var transformers: Dictionary<String, TransformerProtocol>?
    public var futureConnections: Dictionary<String, FutureConnectionProtocol>?
    public var shouldStoreConditions: Dictionary<String, ShouldStoreModelConditionProtocol>?
    public var cherryPickers: Dictionary<String, CherryPickerProtocol>?

    public init(
        idAttributeName: String,
        attributeMapping: AttributeMappingProtocol
        ) {
        self.idAttributeName = idAttributeName
        self.attributeMapping = attributeMapping
    }

    public func add(transformer transformer: TransformerProtocol) {
        if transformers == nil {
            transformers = [:]
        }
        transformers?[transformer.key] = transformer
    }

    public func add(futureConnection connection: FutureConnectionProtocol) {
        if futureConnections == nil {
            futureConnections = [:]
        }
        futureConnections?[connection.relationship.name] = connection
    }

    public func add(cherryPicker picker: CherryPickerProtocol) {
        if cherryPickers == nil {
            cherryPickers = [:]
        }
        cherryPickers?[picker.attributeName] = picker
    }

    public func add(shouldStoreCondition condition: ShouldStoreModelConditionProtocol) {
        if shouldStoreConditions == nil {
            shouldStoreConditions = [:]
        }
        shouldStoreConditions?[condition.attributeName] = condition
    }

    public func shouldStoreCondition(forAttributeName attributeName: String) -> ShouldStoreModelConditionProtocol? {
        let condition = shouldStoreConditions?[attributeName]
        return condition
    }

    public func cherryPicker(forAttributeName attributeName: String) -> CherryPickerProtocol? {
        let picker = cherryPickers?[attributeName]
        return picker
    }

    public func transformer(forKey key: String) -> TransformerProtocol? {
        let transformer = transformers?[key]
        return transformer
    }

    public func futureConnection(forRelationshipName relationshipName: String) -> FutureConnectionProtocol? {
        let connection = futureConnections?[relationshipName]
        return connection
    }
}