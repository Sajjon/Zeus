//
//  JSON.swift
//  Zeus
//
//  Created by Cyon Alexander (Ext. Netlight) on 29/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

internal typealias RawJSON = Dictionary<String, NSObject>

internal protocol JSONProtocol: Sequence {
    var map: RawJSON { get set }
}

internal extension JSONProtocol {

    func makeIterator() -> DictionaryIterator<String, NSObject> {
        return map.makeIterator()
    }

    subscript(key: String) -> NSObject? {
        get {
            return map[key]
        }
        set(newValue) {
            map[key] = newValue
        }
    }
}

internal struct JSON: JSONProtocol {

    internal var map: RawJSON

    internal init(_ map: RawJSON = [:]) {
        self.map = map
    }
}

internal struct MappedJSON: JSONProtocol {

    internal var map: RawJSON

    internal init(_ json: JSON? = nil) {
        self.map = json?.map ?? [:]
    }
}

internal struct CherryPickedJSON: JSONProtocol {

    internal var map: RawJSON

    internal init(_ mappedJson: MappedJSON? = nil) {
        self.map = mappedJson?.map ?? [:]
    }
}
