//
//  MappingContext.swift
//  Zeus
//
//  Created by Cyon Alexander on 22/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

public protocol MappingContextProtocol {
    var responseDescriptors: [ResponseDescriptorProtocol]{get}
    func add(responseDescriptor descriptor: ResponseDescriptorProtocol)
}

open class MappingContext {
    open var responseDescriptors: [ResponseDescriptorProtocol]

    public init() {
        self.responseDescriptors = []
    }

    func add(responseDescriptor descriptor: ResponseDescriptorProtocol) {
        responseDescriptors.append(descriptor)
    }
}
