//
//  HTTPClient.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 23/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import Zeus

protocol HTTPClientProtocol {
    func get(atPath path: APIPath, queryParams: QueryParameters?, options: Options?, done: Done?)
}

class HTTPClient: HTTPClientProtocol {
    static let sharedInstance: HTTPClientProtocol = HTTPClient()

    fileprivate let modelManager: ModelManagerProtocol

    init() {
        self.modelManager = ModelManager.sharedInstance
    }

    func get(atPath path: APIPath, queryParams: QueryParameters?, options: Options?, done: Done?) {
        modelManager.get(atPath: path, queryParameters: queryParams, options: options, done: done)
    }
}
