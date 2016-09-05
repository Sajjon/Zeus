//
//  JSON.swift
//  Zeus
//
//  Created by Cyon Alexander (Ext. Netlight) on 29/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

enum JSON {
    case object(JSONObject)
    case array([JSONObject])
}

typealias RawJSON = Dictionary<String, NSObject>
typealias ValuesForPropertiesNamed = Dictionary<String, NSObject>


struct JSONObject {

    var map: RawJSON
    init(_ map: RawJSON = [:]) {
        self.map = map
    }

    func valueFor(nestedKey: String, inJson rawJson: RawJSON?) -> NSObject? {
        let json = rawJson ?? map

        guard nestedKey.contains(".") else {
            let finalValue = json[nestedKey]
            return finalValue
        }

        let keys = nestedKey.components(separatedBy: ".")
        let slice: ArraySlice<String> = keys.dropFirst()
        let keysWithFirstDropped: [String] = Array(slice)

        let nestedKeyWithoutFirst: String
        if keysWithFirstDropped.count > 1 {
            nestedKeyWithoutFirst = keysWithFirstDropped.reduce("") { return $0 + "." + $1 }
        } else {
            nestedKeyWithoutFirst = keysWithFirstDropped[0]
        }

        let firstKey = keys[0]
        guard let subJson = json[firstKey] as? RawJSON else { return nil }

        return valueFor(nestedKey: nestedKeyWithoutFirst, inJson: subJson)
    }


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

    func valueFor(nestedKey: String) -> NSObject? {
        return valueFor(nestedKey: nestedKey, inJson: map)
    }
    
}
