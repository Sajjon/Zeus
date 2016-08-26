//
//  Error.swift
//  Zeus
//
//  Created by Cyon Alexander on 22/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

public enum Error: Int, ErrorType {
    case AddingSQLiteStore = 10000
    case ParsingJSON = 10100
    case MappingModel = 10200
    case MappingNoResponseDescriptor = 10201
    case MappingOptionsPersist = 10300

    var errorMessage: String {
        let message: String
        switch self {
        case .AddingSQLiteStore:
            message = "Could not add sqlite store"
        case .ParsingJSON:
            message = "JSON could not be serialized into response object"
        case .MappingModel:
            message = "Failed to map model"
        case .MappingNoResponseDescriptor:
            message = "Failed to map model, missing descriptor"
        case .MappingOptionsPersist:
            message = "Your options regarding when to persist models are conflicting with each other"
        }
        return message
    }
}