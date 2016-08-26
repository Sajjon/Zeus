//
//  Options.swift
//  Zeus
//
//  Created by Cyon Alexander (Ext. Netlight) on 26/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

public struct Options {
    public let options: [Option]

    public init(_ option: Option) {
        self.options = [option]
        validate()
    }

    public init(_ options: Option...) {
        self.options = options
        validate()
    }
}

internal extension Options {
    var persistEntities: Bool {
        for option in options {
            guard option.isPersistingOption else { continue }
            return option == .PersistEntitiesDuringMapping
        }
        return false
    }
}

private extension Options {
    private func validate() {
        if let error = validatePersisting() {
            let errorMessage = error.errorMessage
            log.error(errorMessage)
            fatalError(errorMessage)
        }
    }

    private func validatePersisting() -> Error? {
        var foundPersistingOption = false
        for option in options {
            switch (option.isPersistingOption, foundPersistingOption) {
            case (true, true):
                return Error.MappingOptionsPersist
            case (true, _):
                foundPersistingOption = true
            default:
                continue
            }
        }
        return nil
    }
}