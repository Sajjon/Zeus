//
//  ProcessedPayload.swift
//  Zeus
//
//  Created by Cyon Alexander (Ext. Netlight) on 06/09/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

internal protocol ProcessedPayloadProtocol {}

internal protocol DescribedPayloadProtocol: PayloadProtocol {
    var descriptor: ResponseDescriptorProtocol { get }
}

internal struct DescribedPayload: DescribedPayloadProtocol {
    let json: JSON
    let path: APIPathProtocol
    let options: Options
    let descriptor: ResponseDescriptorProtocol

    init(json: JSON, path: APIPathProtocol, options: Options, descriptor: ResponseDescriptorProtocol) {
        self.json = json
        self.path = path
        self.options = options
        self.descriptor = descriptor
    }

    init(payload: PayloadProtocol, descriptor: ResponseDescriptorProtocol) {
        self.init(json: payload.json, path: payload.path, options: payload.options, descriptor: descriptor)
    }
}

internal protocol MappablePayloadProtocol: PayloadProtocol {
    var mapping: MappingProtocol { get }
}

internal struct MappablePayload: MappablePayloadProtocol {
    let json: JSON
    let path: APIPathProtocol
    let options: Options
    let mapping: MappingProtocol

    init(json: JSON, path: APIPathProtocol, options: Options, mapping: MappingProtocol) {
        self.json = json
        self.path = path
        self.options = options
        self.mapping = mapping
    }

    init(described payload: DescribedPayloadProtocol) {
        self.init(json: payload.json, path: payload.path, options: payload.options, mapping: payload.descriptor.mapping)
    }
}
