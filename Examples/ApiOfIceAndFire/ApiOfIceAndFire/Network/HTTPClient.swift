//
//  HTTPClient.swift
//  ApiOfIceAndFire
//
//  Created by Cyon Alexander (Ext. Netlight) on 23/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import Zeus

protocol HTTPClientProtocol {
    func get(atPath path: Router, queryParams: QueryParameters?, done: Done?)
}

class HTTPClient: HTTPClientProtocol {
    static let sharedInstance: HTTPClientProtocol = HTTPClient()

    private let modelManager: ModelManagerProtocol

    init() {
        self.modelManager = ModelManager.sharedInstance
    }

    func get(atPath path: Router, queryParams: QueryParameters?, done: Done?) {
        modelManager.get(atPath: path.path, queryParameters: queryParams, done: done)
    }
}
