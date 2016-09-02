//
//  ModelMapper.swift
//  Zeus
//
//  Created by Alexander Georgii-Hemming Cyon on 26/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData
import DateParser

internal protocol ModelMapperProtocol {
    func model(fromJson json: JSON, withMapping mapping: MappingProtocol, options: Options?) -> Result
    var store: StoreProtocol { get }
}

internal class ModelMapper: ModelMapperProtocol {

    var store: StoreProtocol { fatalError(mustOverride) }

    internal func model(fromJson json: JSON, withMapping mapping: MappingProtocol, options: Options?) -> Result {
        let flattned = flatten(json: json, withMapping: mapping)
        let mappedJson = map(json: flattned, withMapping: mapping)
        guard shouldStoreModel(mappedJson, withMapping: mapping) else {
            log.verbose("Not storing model with json: \(json) since it does not fulfill store condition")
            return Result(.eventMappingSkipped)
        }
        let result = storeModel(mappedJson, withMapping: mapping, options: options)
        return result
    }

    internal func shouldStoreModel(_ json: MappedJSON, withMapping mapping: MappingProtocol) -> Bool {
        guard let conditions = mapping.shouldStoreConditions else { return true }

        for (attributeName, attributeValue) in json {
            guard let condition = conditions[attributeName] else { continue }
            let currentValue: Attribute? = currentValueFor(attributeNamed: attributeName, fromJson: json, withMapping: mapping, forClazz: mapping.destinationClass)
            guard incomingAttribute(attributeValue, fullfillsCondition: condition, compareTo: currentValue) else { return false }
        }

        return true
    }

    internal func currentValueFor<T: NSObject>(attributeNamed name: String, fromJson json: MappedJSON, withMapping mapping: MappingProtocol, forClazz clazz: T.Type) -> Attribute? {
        var maybeCurrentValue: Attribute?
        if let existing = store.existingModel(fromJson: json, withMapping: mapping) as? T {
            maybeCurrentValue = existing.value(forKey: name) as? Attribute
        }
        return maybeCurrentValue
    }

    internal func incomingAttribute(_ incomingAttribute: Attribute, fullfillsCondition condition: ShouldStoreModelConditionProtocol, compareTo currentValue: Attribute?) -> Bool {
        let fullfills = condition.shouldStore(incomingAttribute, currentValue)
        return fullfills
    }

    internal func cherryPick(from json: MappedJSON, withMapping mapping: MappingProtocol) -> CherryPickedJSON {
        guard let cherryPickers = mapping.cherryPickers else { return CherryPickedJSON(json) }
        var cherryPickedValues = CherryPickedJSON(json)
        for (attributeName, attributeValue) in json {
            guard let
                cherryPicker = cherryPickers[attributeName],
                let currentValue = currentValueFor(attributeNamed: attributeName, fromJson: json, withMapping: mapping, forClazz: mapping.destinationClass)
            else { continue }
            let cherryPickedValue = cherryPicker.valueToStore(attributeValue, currentValue)
            cherryPickedValues[attributeName] = cherryPickedValue
        }
        return cherryPickedValues
    }

    internal func storeModel(_ json: MappedJSON, withMapping mapping: MappingProtocol, options: Options?) -> Result {
        let jsonPair = split(json: json, withMapping: mapping)
        let relationshipJson = jsonPair.relationship
        let attributesJson = jsonPair.attributes

        var maybeModel: NSObject?
        if let existing = existingModel(fromJson: attributesJson, withMapping: mapping) {
            maybeModel = existing
        } else if let new = newModel(fromJson: attributesJson, withMapping: mapping) {
            maybeModel = new
        }
        guard let model = maybeModel else { return Result(ZeusError.mappingModel) }
        setValuesFor(attributes: attributesJson, inModel: model, withMapping: mapping)
        return Result(model)
    }

    internal func setValuesFor(attributes attributesJson: MappedJSON, inModel model: NSObject, withMapping mapping: MappingProtocol) {
        let cherryPicked = cherryPick(from: attributesJson, withMapping: mapping)
        model.setValuesForProperties(cherryPicked.map, for: mapping.destinationClass)
    }

    internal func split(json: MappedJSON, withMapping mapping: MappingProtocol) -> (relationship: MappedJSON, attributes: MappedJSON) {
        return (relationship: json, attributes: json)
    }

    internal func existingModel(fromJson json: MappedJSON, withMapping mapping: MappingProtocol) -> NSObject? {
        let existing = store.existingModel(fromJson: json, withMapping: mapping)
        return existing
    }

    internal func newModel(fromJson json: MappedJSON, withMapping mapping: MappingProtocol) -> NSObject? {
        fatalError(mustOverride)
    }
}

private extension ModelMapper {

    /*
        This function filters out the interesting values that exists in the attributes mapping dictionary from the json.
        Apart from that it also flattens out the json, for any nested keys (keys containing dots).
     */
    func flatten(json: JSON, withMapping mapping: MappingProtocol) -> FlattnedJSON {
        var noDots = FlattnedJSON()

        for (mapKey, _) in mapping.attributeMapping.mapping {
            guard mapKey.contains("."), let value = json.valueFor(nestedKey: mapKey) else {
                noDots[mapKey] = json[mapKey]
                continue
            }
            noDots[mapKey] = value
        }
        return noDots
    }

    func map(json: FlattnedJSON, withMapping mapping: MappingProtocol) -> MappedJSON {
        var mappedJson: MappedJSON = MappedJSON()
        for (key, value) in json {
            guard let mappedKey = map(key: key, toAttributeWithMapping: mapping.attributeMapping) else { continue }
            
            let transformedValue = transform(value: value, forKey: key, withMapping: mapping)
            mappedJson[mappedKey] = transformedValue
        }
        return mappedJson
    }

    func map(key: String, toAttributeWithMapping mapping: AttributeMappingProtocol) -> String? {
        var mappedKey: String?
        for (mappingKey, value) in mapping.mapping {
            guard mappingKey == key else { continue }
            mappedKey = value
        }
        return mappedKey
    }

    func transform(value: NSObject, forKey key: String, withMapping mapping: MappingProtocol) -> NSObject? {
        guard let transformers = mapping.transformers, let transformer = transformers[key] else { return value }
        let transformedValue = transformer.transform(value: value)
        return transformedValue
    }

    func makeConnections(withMapping mapping: MappingProtocol, forModel model: NSManagedObject) {

    }
}

protocol DateParserProtocol {
    func parseDate(from dateString: String) -> Date?
}

class DateParser: DateParserProtocol {

    func parseDate(from object: NSObject) -> Date? {
        guard let dateString = object as? String else { return nil }
        return parseDate(from: dateString)
    }

    func parseDate(from dateString: String) -> Date? {
        let date = Date(dateString: dateString)
        return date
    }
}

extension NSObject {
    func setValuesForProperties(_ propertyValues: ValuesForPropertiesNamed, for clazz: NSObject.Type) {
        // This line makes app crash if the object contains a NSDate property. Because we have not parsed the date string from String -> NSDate...
        // We wanna solve this by reflection somehow...?

        for (propertyName, value) in propertyValues {
            let valueOfPropery: Any
            if isProperty(named: propertyName, ofType: NSDate.self, in: clazz) {
                guard let date = DateParser().parseDate(from: value) else { log.error("Failed to parse date"); return }
                valueOfPropery = date
            } else {
                valueOfPropery = value
            }
            setValue(valueOfPropery, forKey: propertyName)
        }
    }
}
