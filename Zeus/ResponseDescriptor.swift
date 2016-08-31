//
//  ResponseDescriptor.swift
//  Zeus
//
//  Created by Cyon Alexander on 22/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import Alamofire

public protocol APIPathProtocol {
    var method: HTTPMethod { get }
    var mapping: String { get }
    func request(baseUrl: String) -> String
}

public protocol ResponseDescriptorProtocol {
    var mapping: MappingProtocol { get }
    var apiPath: APIPathProtocol { get }
    var jsonKeyPath: String? { get }
}


public struct ResponseDescriptor: ResponseDescriptorProtocol {

    public let mapping: MappingProtocol
    public let apiPath: APIPathProtocol
    public let jsonKeyPath: String?

    public init(mapping: MappingProtocol, apiPath: APIPathProtocol, jsonKeyPath: String? = nil) {
        self.mapping = mapping
        self.apiPath = apiPath
        self.jsonKeyPath = jsonKeyPath
    }
}
