//
//  JSON.swift
//  Zeus
//
//  Created by Cyon Alexander (Ext. Netlight) on 06/09/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

enum JSON {
    case object(JSONObject)
    case array([JSONObject])

    internal init(_ object: JSONObject) {
        self = .object(object)
    }

    internal init(_ array: [JSONObject]) {
        self = .array(array)
    }

    var isObject: Bool {
        switch self {
        case .object:
            return true
        case .array:
            return false
        }
    }

    var isArray: Bool {
        return !isObject
    }

    var object: JSONObject? {
        switch self {
        case .object(let object):
            return object
        case .array:
            return nil
        }
    }

    var array: [JSONObject]? {
        switch self {
        case .object:
            return nil
        case .array(let array):
            return array
        }
    }

}
