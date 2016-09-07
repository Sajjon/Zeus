//
//  JSON.swift
//  Zeus
//
//  Created by Cyon Alexander (Ext. Netlight) on 29/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

typealias RawJSON = Dictionary<String, NSObject>
typealias ValuesForPropertiesNamed = Dictionary<String, NSObject>

/**
 It is super important that the JSONObject is a class and not a struct. Becuase the mapper uses recursion to manipulate this object and we want to change the only instance of the JSON, i.e. manipulate by reference and not by value.
 */
class JSONObject {

    var map: RawJSON
    init(_ map: RawJSON = [:]) {
        self.map = map
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

    func json(for nestedKey: String) -> JSON? {
        guard let nestedValue = valueFor(nestedKey: nestedKey) else { return nil }

        var json: JSON?
        if let rawJsonArray = nestedValue as? [RawJSON] {
            let jsonArray: [JSONObject] = rawJsonArray.map { return JSONObject($0) }
            json = JSON(jsonArray)
        } else if let rawJson = nestedValue as? RawJSON {
            let jsonObject = JSONObject(rawJson)
            json = JSON(jsonObject)
        }
        return json
    }

    func valueFor(nestedKey: String) -> NSObject? {
        return valueFor(nestedKey: nestedKey, inJson: map)
    }
    
}

private extension JSONObject {
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
}
