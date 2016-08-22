//
//  MappingProxy.swift
//  Zeus
//
//  Created by Cyon Alexander (Ext. Netlight) on 22/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

public struct MappingProxy {
    var context: MappingContext
    let mapping: MappingProtocol
}

public func ==(mappingProxy: MappingProxy, route: RouterProtocol) -> ResponseDescriptorProtocol {
    let descriptor = ResponseDescriptor(mapping: mappingProxy.mapping, route: route)
    mappingProxy.context.add(responseDescriptor: descriptor)
    return descriptor
}