//
//  Option.swift
//  Zeus
//
//  Created by Cyon Alexander (Ext. Netlight) on 26/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

public enum Option: Int {
    case PersistEntitiesDuringMapping
    case DontPersistEntitiesDuringMapping
}

internal extension Option {
    var isPersistingOption: Bool {
        switch self {
        case .PersistEntitiesDuringMapping: fallthrough
        case .DontPersistEntitiesDuringMapping:
            return true
        default:
            return false
        }
    }
}