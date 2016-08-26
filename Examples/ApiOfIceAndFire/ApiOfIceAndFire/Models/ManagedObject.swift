//
//  ManagedObject.swift
//  ApiOfIceAndFire
//
//  Created by Cyon Alexander (Ext. Netlight) on 23/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData
import Zeus

let mustOverride = "must override"
class ManagedObject: NSManagedObject, MappableEntity {

    class var destinationClass: NSObject.Type {
        return entity
    }
    class var entity: NSManagedObject.Type {
        return self
    }
    class var idAttributeName: String { fatalError(mustOverride) }
    class var attributeMapping: AttributeMappingProtocol { fatalError(mustOverride) }
    class var transformers: [TransformerProtocol]? { return nil }
    class var cherryPickers: [CherryPickerProtocol]? { return nil }
    class var shouldStoreModelCondtions: [ShouldStoreModelConditionProtocol]? { return nil }
    class func futureConnections(forMapping mapping: MappingProtocol) -> [FutureConnectionProtocol]? {return nil}
}