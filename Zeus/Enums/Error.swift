//
//  ZeusError.swift
//  Zeus
//
//  Created by Cyon Alexander on 22/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

public enum ZeusError: Int, Error {
    case addingSQLiteStore = 10000
    case parsingJSON = 10100
    case mappingModel = 10200
    case mappingNoResponseDescriptor = 10201
    case mappingOptionsPersist = 10300
    case coreDataValidation = 10400

    case eventMappingSkipped = 11000

    var errorMessage: String {
        let message: String
        switch self {
        case .addingSQLiteStore:
            message = "Could not add sqlite store"
        case .parsingJSON:
            message = "JSON could not be serialized into response object"
        case .mappingModel:
            message = "Failed to map model"
        case .mappingNoResponseDescriptor:
            message = "Failed to map model, missing descriptor"
        case .mappingOptionsPersist:
            message = "Your options regarding when to persist models are conflicting with each other"
        case .coreDataValidation:
            message = "Model does not fulfill the required attributes"
        case .eventMappingSkipped:
            message = "You have added a condition for the object being mapped that prevented it from being stored"
        }
        return message
    }

    var error: NSError {
        let userInfo = [NSLocalizedFailureReasonErrorKey: errorMessage]
        let error = NSError(domain: "Zeus", code: rawValue, userInfo: userInfo)
        return error
    }

    var isEvent: Bool {
        let isEvent: Bool
        switch self {
        case .eventMappingSkipped:
            isEvent = true
        default:
            isEvent = false
        }
        return isEvent
    }
}
