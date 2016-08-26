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
public typealias ShouldStoreModelClosure = (incomingValue: Attribute, maybeCurrentValue: Attribute?) -> Bool

public protocol ShouldStoreModelConditionProtocol {
    var attributeName: String { get }
    var shouldStore: ShouldStoreModelClosure { get }
}

public struct ShouldStoreModelCondition: ShouldStoreModelConditionProtocol {
    public let attributeName: String
    public let shouldStore: ShouldStoreModelClosure
    public init(attributeName: String, closure: ShouldStoreModelClosure) {
        self.attributeName = attributeName
        self.shouldStore = closure
    }
}