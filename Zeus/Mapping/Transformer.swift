//
//  Transformer.swift
//  Zeus
//
//  Created by Cyon Alexander (Ext. Netlight) on 23/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

public typealias Transformation = (NSObject) -> NSObject
public typealias StringTransformation = (NSString) -> NSObject
public typealias URLTransformation = (NSURL) -> NSObject

public protocol TransformerProtocol {
    var transformation: Transformation {get}
    var key: String {get}
}

internal extension TransformerProtocol {
    func transform(value: NSObject) -> NSObject {
        if let array = value as? [NSObject] {
            return transform(array: array)
        }
        let transformed = transformation(value)
        return transformed
    }

    func transform(array arrayToTranform: [NSObject]) -> NSArray {
        let transformedArray: NSMutableArray = NSMutableArray()
        for value in arrayToTranform {
            let transformed = transformation(value)
            transformedArray.add(transformed)
        }
        return transformedArray
    }
}

open class Transformer: TransformerProtocol {
    open let transformation: Transformation
    open let key: String
    public init(key: String, transformation: Transformation) {
        self.key = key
        self.transformation = transformation
    }
}

open class StringTransformer: Transformer {
    override public init(key: String, transformation: StringTransformation) {
        let castedTransformation: Transformation = {
            (obj: NSObject) -> NSObject in
            guard let string = obj as? NSString else { return obj }
            return transformation(string)
        }
        super.init(key: key, transformation: castedTransformation)
    }
}

open class URLTransformer: StringTransformer {
    public init(key: String, transformation: URLTransformation) {
        let castedTransformation: StringTransformation = {
            (urlString: NSString) -> NSObject in

            guard let url = NSURL(string: urlString as String) else { return urlString}
            return transformation(url)

        }
        super.init(key: key, transformation: castedTransformation)
    }
}

open class URLToIdTransformer: URLTransformer {
    public init(key: String) {
        let transformation: URLTransformation = {
            (url: NSURL) -> NSObject in

            guard let lastPath = url.lastPathComponent
                else { return url }

            let asId = lastPath as NSString
            return asId
        }
        super.init(key: key, transformation: transformation)
    }
}
