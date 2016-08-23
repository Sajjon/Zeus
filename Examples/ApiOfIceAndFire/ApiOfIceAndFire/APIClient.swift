//
//  APIClient.swift
//  ApiOfIceAndFire
//
//  Created by Cyon Alexander (Ext. Netlight) on 23/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import Zeus

protocol APIClientProtocol {
    func getHouses(queryParams queryParams: QueryParameters?, done: Done?)
}

class APIClient: APIClientProtocol {
    static let sharedInstance: APIClientProtocol = APIClient()

    private let httpClient: HTTPClientProtocol

    init() {
        self.httpClient = HTTPClient.sharedInstance
    }

    func getHouses(queryParams queryParams: QueryParameters?, done: Done?) {
        httpClient.get(atPath: .Houses, queryParams: queryParams, done: done)
    }
}
