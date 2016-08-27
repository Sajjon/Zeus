//
//  Result.swift
//  Zeus
//
//  Created by Cyon Alexander on 22/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

public struct Result {
    public let data: NSObject?
    public let error: NSError?
    internal let mappingEvent: MappingEvent?

    init(_ error: Zeus.Error) {
        self.init(error: err(error))
    }

    init(_ model: NSObject) {
        self.init(data: model)
    }

    init(_ event: MappingEvent) {
        self.init(event: event)
    }

    init(data: NSObject? = nil, error: NSError? = nil, event: MappingEvent? = nil) {
        validate(data, error: error, event: event)
        self.data = data
        self.error = error
        self.mappingEvent = event
    }
}

private func validate(_ data: NSObject? = nil, error: NSError? = nil, event: MappingEvent? = nil) {
    if event == nil {
        let bothNil = data == nil && error == nil
        let noneNil = data != nil && error != nil
        guard !bothNil && !noneNil else { fatalError("Data and error cant be nil or not nil at the same time") }
    } else {
        guard data == nil && error == nil else { fatalError("Should not contain 'event' together with neither 'data' nor 'error'") }
    }
}

internal enum MappingEvent: Int, CustomStringConvertible {
    case skippedDueToCondition

    var description: String {
        let message: String
        switch self {
        case .skippedDueToCondition:
            message = "You have added a condition for the object being mapped that prevented it from being stored"
        }
        return message
    }
}
