//
//  JsonProcessor.swift
//  Zeus
//
//  Created by Cyon Alexander (Ext. Netlight) on 06/09/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

//
//struct MapJob {
//    let json: JSONObject
//    let destinationClass: NSObject.Type
//}
//
//indirect enum ProcessJob {
//    case root(MapJob)
//    case relationships([MapJob])
//}
//
//protocol MapPayload {
//    var job: ProcessJob { get }
//}

struct RelationshipPayload {
    let json: JSON
    let name: String
    let mapping: MappingProtocol
}

internal protocol JsonProcessorProtocol {
    var descriptor: ResponseDescriptorProtocol { get }
    func process(_ payload: PayloadProtocol) -> IntermediateResult
}

internal class JsonProcessor: JsonProcessorProtocol {

    internal let descriptor: ResponseDescriptorProtocol

    init(descriptor: ResponseDescriptorProtocol) {
        self.descriptor = descriptor
    }
}

//MARK: JsonProcessorProtocol Methods
extension JsonProcessorProtocol {
    internal func process(_ payload: PayloadProtocol) -> IntermediateResult {
        let describedPayload = DescribedPayload(payload: payload, descriptor: descriptor)
        return process(described: describedPayload)
    }
}

private extension JsonProcessorProtocol {

    func process(described payload: DescribedPayloadProtocol) -> IntermediateResult {
        let relevantPayload = relevant(from: payload)
        let processed = process(relevantPayload)
        return processed
    }

    func relevant(from payload: DescribedPayloadProtocol) -> DescribedPayloadProtocol {
        guard
            let object = payload.json.object,
            let keyPath = payload.descriptor.jsonKeyPath,
            let relevantJson = object.json(for: keyPath)
        else { return payload }
        return DescribedPayload(json: relevantJson, path: payload.path, options: payload.options, descriptor: payload.descriptor)
    }

    func process(relevant payload: DescribedPayloadProtocol) -> IntermediateResult {
        let mappedPayload = MappablePayload(described: payload)
        return process(mapped: mappedPayload)
    }

    /**

     */
    func process(mapped payload: MappablePayloadProtocol) -> MappablePayloadProtocol {
        switch payload.json {
        case .array(let array):
            var processedArray: [MappablePayloadProtocol] = []
            for object in array {
                let processed = process(jsonObject: object, payload: payload)
                processedArray.append(processed)
            }
            return processedArray
        case .object(let object):
            let processed = process(jsonObject: object, payload: payload)
            return processed
        }
        fatalError()
    }

    func process(jsonObject object: JSONObject, payload: MappablePayloadProtocol) -> MappablePayloadProtocol {
        // Select the interesting attributes that was mapped
        var attribtutes: RawJSON = [:]
        for (jsonKey, attributeName) in payload.mapping.attributeMapping.mapping {
            guard let implicitlyTransformed = implicitlyTransform(forAttributeNamed: attributeName, jsonKey: jsonKey, in: object, payload: payload) else { continue }
            attribtutes[attributeName] = implicitlyTransformed
        }

        var relationPayloads: Dictionary<String, RelationshipPayload> = [:]
        if let relationships = payload.mapping.relationships {
            for (_, relationship) in relationships {
                guard let relationshipJson = object.json(for: relationship.sourceKeyPath) else { continue }
                let relationshipPayloadToProcess = MappablePayload(json: relationshipJson, path: payload.path, options: payload.options, mapping: relationship.mapping)
                // Recursivly process relationship
                let proccessedRelationship = process(mapped: relationshipPayloadToProcess)
                let relationshipPayload = RelationshipPayload(json: proccessedRelationship.json, name: relationship.destinationKeyPath, mapping: relationship.mapping)
                relationPayloads[relationship.destinationKeyPath] = relationshipPayload
            }
        }
        fatalError()
    }

    func implicitlyTransform(forAttributeNamed attributeName: String, jsonKey: String, in object: JSONObject, payload: MappablePayloadProtocol) -> Attribute? {
        guard let valueRawValue = object.valueFor(nestedKey: jsonKey) else { return nil }
        let valueOfPropery: Attribute
        if isProperty(named: attributeName, ofType: NSDate.self, in: payload.mapping.destinationClass) {
            guard let date = DateParser().parseDate(from: valueRawValue) else { log.error("Failed to parse date"); return valueRawValue }
            let nsDate = date as NSDate
            valueOfPropery = nsDate
        } else {
            valueOfPropery = valueRawValue
        }
        return valueOfPropery
    }




//    func split(json: JSONObject, withMapping mapping: MappingProtocol) -> (relationship: JSONObject, attributes: JSONObject) {
//        return (relationship: json, attributes: json)
//    }


    func flattRelationships(in payload: ProcessedPayloadProtocol) -> IntermediateResult {
        fatalError()
    }

    func flattenedRelationship(for name: String, in payload: ProcessedPayloadProtocol) -> IntermediateResult {
        fatalError()
    }
}
