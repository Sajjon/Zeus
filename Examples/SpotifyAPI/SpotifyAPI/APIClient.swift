//
//  APIClient.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 23/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import Zeus

protocol APIClientProtocol {
    func getAlbum(byId id: String, queryParams: QueryParameters?, done: Done?)
    func getArtist(byId id: String, queryParams: QueryParameters?, done: Done?)
    func getAlbums(byArtist artistId: String, queryParams: QueryParameters?, done: Done?)
}

class APIClient: APIClientProtocol {
    static let sharedInstance: APIClientProtocol = APIClient()

    fileprivate let httpClient: HTTPClientProtocol

    init() {
        self.httpClient = HTTPClient.sharedInstance
    }

    func getAlbum(byId id: String, queryParams: QueryParameters?, done: Done?) {
        httpClient.get(atPath: .albumById(id), queryParams: queryParams, options: nil, done: done)
    }

    func getAlbums(byArtist artistId: String, queryParams: QueryParameters?, done: Done?) {
        httpClient.get(atPath: .albumsByArtist(artistId), queryParams: queryParams, options: nil, done: done)
    }

    func getArtist(byId id: String, queryParams: QueryParameters?, done: Done?) {
        httpClient.get(atPath: .artistById(id), queryParams: queryParams, options: nil, done: done)
    }
}
