//
//  MappingProxy.swift
//  Zeus
//
//  Created by Cyon Alexander on 22/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

public struct MappingProxy {
    var context: MappingContext
    let mapping: MappingProtocol
}

public struct KeyPathMappingProxy {
    let apiPath: APIPathProtocol
    let jsonKeyPath: String
}

@discardableResult
public func ==(mappingProxy: MappingProxy, apiPath: APIPathProtocol) -> ResponseDescriptorProtocol {
    let descriptor = ResponseDescriptor(mapping: mappingProxy.mapping, apiPath: apiPath)
    mappingProxy.context.add(responseDescriptor: descriptor)
    return descriptor
}

@discardableResult
public func ==(mappingProxy: MappingProxy, keyPathMappingProxy: KeyPathMappingProxy) -> ResponseDescriptorProtocol {
    let descriptor = ResponseDescriptor(mapping: mappingProxy.mapping, apiPath: keyPathMappingProxy.apiPath, jsonKeyPath: keyPathMappingProxy.jsonKeyPath)
    mappingProxy.context.add(responseDescriptor: descriptor)
    return descriptor
}

/** 
 Make this: 
    someMapping == APIPathProtocol.somePath << "myKeyPath" 
 
 be parsed as:
   someMapping == (APIPathProtocol.somePath << "myKeyPath")
 */
precedencegroup BitwiseShiftPrecedence { higherThan: ComparisonPrecedence }

public func <<(apiPath: APIPathProtocol, jsonKeyPath: String) -> KeyPathMappingProxy {
    return KeyPathMappingProxy(apiPath: apiPath, jsonKeyPath: jsonKeyPath)
}
