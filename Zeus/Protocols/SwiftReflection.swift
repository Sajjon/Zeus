//
//  SwiftReflection.swift
//  SwiftReflection
//
//  Created by Cyon Alexander (Ext. Netlight) on 01/09/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import ObjectiveC.runtime

protocol ReflectionProtocol {
    static func getTypesOfProperties(inClass clazz: NSObject.Type) -> Dictionary<String, Any>?
    static func getTypesOfProperties(ofObject object: NSObject) -> Dictionary<String, Any>?
}

/*
 Please note that the class you are inspecting have to inherit from NSObject.

 This tool can find the name and type of properties of type NSObject, e.g. NSString (or just "String" with Swift 3 syntax), NSDate (or just "NSDate" with Swift 3 syntax), NSNumber etc.
 It also works with optionals and implicit optionals for said types, e.g. String?, String!, Date!, Date? etc...

 This tool can also find name and type of "primitive data types" such as Bool, Int, Int32, _HOWEVER_ it does not work if said primitive have optional type, e.g. Int? <--- DOES NOT WORK
 */
open class SwiftReflection: ReflectionProtocol {

    public class func getTypesOfProperties(inClass clazz: NSObject.Type) -> Dictionary<String, Any>? {
        var count = UInt32()
        guard let properties = class_copyPropertyList(clazz, &count) else { return nil }
        var types: Dictionary<String, Any> = [:]
        for i in 0..<Int(count) {
            guard let property: objc_property_t = properties[i], let name = getNameOf(property: property) else { continue }
            let type = getTypeOf(property: property)
            types[name] = type
        }
        free(properties)
        return types
    }

    public class func getTypesOfProperties(ofObject object: NSObject) -> Dictionary<String, Any>? {
        let clazz: NSObject.Type = type(of: object)
        return getTypesOfProperties(inClass: clazz)
    }
}

private extension SwiftReflection {
    class func getTypeOf(property: objc_property_t) -> Any {
        guard let attributesAsNSString: NSString = NSString(utf8String: property_getAttributes(property)) else { return Any.self }
        let attributes = attributesAsNSString as String
        let slices = attributes.components(separatedBy: "\"")
        guard slices.count > 1 else { return getPrimitiveDataType(withAttributes: attributes) }
        let objectClassName = slices[1]
        let objectClass = NSClassFromString(objectClassName) as! NSObject.Type
        return objectClass
    }

    class func getPrimitiveDataType(withAttributes attributes: String) -> Any {
        guard let letter = attributes.substring(from: 1, to: 2), let type = primitiveDataTypes[letter] else { return Any.self }
        return type
    }

    class func getNameOf(property: objc_property_t) -> String? {
        guard let name: NSString = NSString(utf8String: property_getName(property)) else { return nil }
        return name as String
    }
}

fileprivate let primitiveDataTypes: Dictionary<String, Any> = [
    "c" : Int8.self,
    "s" : Int16.self,
    "i" : Int32.self,
    "q" : Int.self, //also: Int64, NSInteger, only true on 64 bit platforms
    "S" : UInt16.self,
    "I" : UInt32.self,
    "Q" : UInt.self, //also UInt64, only true on 64 bit platforms
    "B" : Bool.self,
    "d" : Double.self,
    "f" : Float.self,
    "{" : Decimal.self
]

extension String {
    func substring(from fromIndex: Int, to toIndex: Int) -> String? {
        let substring = self[self.index(self.startIndex, offsetBy: fromIndex)..<self.index(self.startIndex, offsetBy: toIndex)]
        return substring
    }
}
