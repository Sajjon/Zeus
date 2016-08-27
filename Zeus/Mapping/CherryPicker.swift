//
//  CherryPicker.swift
//  Zeus
//
//  Created by Alexander Georgii-Hemming Cyon on 25/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

/**

let cherryPicker = CherryPicker(attributeName: "latestUpdated") {
    (incomingValue: Attribute, currentValue: Attribute) -> Attribute in

    let pickedValue = incomingValue > currentValue ? incomingValue : currentValue
    return pickedValue
}

*/
public typealias CherryPickingClosure = (_ incomingValue: Attribute, _ currentValue: Attribute) -> Attribute

public protocol CherryPickerProtocol {
    var attributeName: String { get }
    var valueToStore: CherryPickingClosure { get }
}

public struct CherryPicker: CherryPickerProtocol {
    public let attributeName: String
    public let valueToStore: CherryPickingClosure
    public init(attributeName: String, closure: CherryPickingClosure) {
        self.attributeName = attributeName
        self.valueToStore = closure
    }
}
