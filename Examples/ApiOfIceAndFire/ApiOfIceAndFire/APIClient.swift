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
    func getHouses(queryParams: QueryParameters?, done: Done?)
    func getHouse(byId id: String, queryParams: QueryParameters?, done: Done?)
    func getCharacter(byId id: String, queryParams: QueryParameters?, done: Done?)
}

class APIClient: APIClientProtocol {
    static let sharedInstance: APIClientProtocol = APIClient()

    fileprivate let httpClient: HTTPClientProtocol

    init() {
        self.httpClient = HTTPClient.sharedInstance
    }

    func getHouses(queryParams: QueryParameters?, done: Done?) {
        httpClient.get(atPath: .houses, queryParams: queryParams, options: nil, done: done)
    }

    func getHouse(byId id: String, queryParams: QueryParameters?, done: Done?) {
        httpClient.get(atPath: .houseById(id), queryParams: queryParams, options: nil, done: done)
    }

    func getCharacter(byId id: String, queryParams: QueryParameters?, done: Done?) {
        httpClient.get(atPath: .characterById(id), queryParams: queryParams, options: nil, done: done)
    }
}
