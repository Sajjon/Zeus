//
//  ResponseDescriptor.swift
//  Zeus
//
//  Created by Cyon Alexander on 22/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import Alamofire

public protocol ResponseDescriptorProtocol {
    var mapping: MappingProtocol{get}
    var route: RouterProtocol{get}
}

public protocol RouterProtocol {
    var method: HTTPMethod{get}
    var path: String{get}
}

public struct ResponseDescriptor: ResponseDescriptorProtocol {

    public let mapping: MappingProtocol
    public let route: RouterProtocol

    public init(mapping: MappingProtocol, route: RouterProtocol) {
        self.mapping = mapping
        self.route = route
    }
}