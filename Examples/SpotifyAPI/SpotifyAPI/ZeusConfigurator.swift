//
//  ZeusConfigurator.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 23/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import Zeus

private let baseUrl = "https://api.spotify.com/v1/"
class ZeusConfigurator {

    var store: DataStoreProtocol!
    var modelManager: ModelManagerProtocol!

    init() {
        setup()
    }

    fileprivate func setup() {
        setupCoreDataStack()
        setupLogging()
        setupMapping()
    }

    fileprivate func setupLogging() {
        Zeus.logLevel = .Warning
    }

    fileprivate func setupCoreDataStack() {
        store = DataStore()
        modelManager = ModelManager(baseUrl: baseUrl, store: store)
        DataStore.sharedInstance = store
        ModelManager.sharedInstance = modelManager
    }

    fileprivate func setupMapping() {
        modelManager.map(Artist.entityMapping(store), Album.entityMapping(store)) {
            artist, album in
            artist == Router.artistById(noId)
            album == Router.albumById(noId)
        }
    }
}
