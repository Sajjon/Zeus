//
//  ZeusConfigurator.swift
//  ApiOfIceAndFire
//
//  Created by Cyon Alexander (Ext. Netlight) on 23/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import Zeus

private let baseUrl = "http://anapioficeandfire.com/api/"
class ZeusConfigurator {

    var store: DataStoreProtocol!
    var modelManager: ModelManagerProtocol!

    init() {
        setup()
    }

    private func setup() {
        setupCoreDataStack()
        setupLogging()
        setupMapping()
    }

    private func setupLogging() {
        Zeus.logLevel = .Verbose
    }

    private func setupCoreDataStack() {
        store = DataStore()
        modelManager = ModelManager(baseUrl: baseUrl, store: store)
        DataStore.sharedInstance = store
        ModelManager.sharedInstance = modelManager
    }

    private func setupMapping() {
        modelManager.map(Character.mapping(store), House.mapping(store)) {
            character, house in
            character == Router.Characters
            character == Router.CharacterById(nil)
            house == Router.Houses
            house == Router.HouseById(nil)
        }
    }
}