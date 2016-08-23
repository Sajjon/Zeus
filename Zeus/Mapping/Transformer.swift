//
//  Transformer.swift
//  Zeus
//
//  Created by Cyon Alexander (Ext. Netlight) on 23/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

public protocol TransformerProtocol {
    var transformation: (NSObject?) -> NSObject? {get}
    var key: String {get}
}

internal extension TransformerProtocol {
    func transform(value value: NSObject) -> NSObject? {
        if let array = value as? [NSObject] {
            return transform(array: array)
        }
        let transformed = transformation(value)
        return transformed
    }

    func transform(array arrayToTranform: [NSObject]) -> NSArray? {
        var transformedArray: [NSObject] = []
        for value in arrayToTranform {
            guard let transformed = transformation(value) else { continue }
            transformedArray.append(transformed)
        }
        return transformedArray
    }
}

public class Transformer: TransformerProtocol {
    public let transformation: (NSObject?) -> NSObject?
    public let key: String
    public init(key: String, transformation: (NSObject?) -> NSObject?) {
        self.key = key
        self.transformation = transformation
    }
}