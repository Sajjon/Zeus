//
//  Option.swift
//  Zeus
//
//  Created by Cyon Alexander (Ext. Netlight) on 26/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

public enum Option: Int {
    case persistEntitiesDuringMapping
    case dontPersistEntitiesDuringMapping
}

internal extension Option {
    var isPersistingOption: Bool {
        switch self {
        case .persistEntitiesDuringMapping: fallthrough
        case .dontPersistEntitiesDuringMapping:
            return true
        default:
            return false
        }
    }
}
