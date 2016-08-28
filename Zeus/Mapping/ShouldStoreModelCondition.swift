//
//  ShouldStoreModelCondition.swift
//  Zeus
//
//  Created by Alexander Georgii-Hemming Cyon on 25/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

/**
 
let shouldUpdateCondition = ShouldStoreModelCondition(attributeName: "latestUpdated"){
    (incomingValue: Attribute, maybeCurrentValue: Attribute?) -> Bool in
 
    let shouldUpdate = incomingValue > currentValue
    return shouldUpdate
}

*/
public typealias StoreCondition = (_ incomingValue: Attribute, _ maybeCurrentValue: Attribute?) -> Bool
public typealias StoreConditionString = (_ incomingValue: String, _ maybeCurrentValue: String?) -> Bool

public protocol ShouldStoreModelConditionProtocol {
    var attributeName: String { get }
    var shouldStore: StoreCondition { get }
}

public class ShouldStoreModelCondition: ShouldStoreModelConditionProtocol {
    public let attributeName: String
    public let shouldStore: StoreCondition
    public init(attributeName: String, closure: StoreCondition) {
        self.attributeName = attributeName
        self.shouldStore = closure
    }
}

public class StoreModelConditionString: ShouldStoreModelCondition {

    public init(attributeName: String, closure: StoreConditionString) {
        let wrappingClosure: StoreCondition = {
            (incomingValue: Attribute, maybeCurrent: Attribute?) in
            guard let incomingNSString = (incomingValue as? NSString) else { return true }
            let incomingString = incomingNSString as String
            let maybeCurrentNSString = maybeCurrent as? NSString
            let maybeCurrentString = maybeCurrentNSString as? String
            return closure(incomingString, maybeCurrentString)
        }
        super.init(attributeName: attributeName, closure: wrappingClosure)
    }
}
