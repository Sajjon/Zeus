//
//  Error.swift
//  Zeus
//
//  Created by Cyon Alexander on 22/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

public enum Error: Int, Error {
    case addingSQLiteStore = 10000
    case parsingJSON = 10100
    case mappingModel = 10200
    case mappingNoResponseDescriptor = 10201
    case mappingOptionsPersist = 10300

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
        }
        return message
    }
}
