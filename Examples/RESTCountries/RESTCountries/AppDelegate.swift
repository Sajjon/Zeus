//
//  AppDelegate.swift
//  RESTCountries
//
//  Created by Cyon Alexander (Ext. Netlight) on 19/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import UIKit
import Zeus
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder {

    var zeusConfig: ZeusConfigurator!
    var window: UIWindow?

}

extension AppDelegate: UIApplicationDelegate {
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        zeusConfig = ZeusConfigurator()
        return true
    }
}

private let baseUrl = "http://anapioficeandfire.com/api/"
let mustOverride = "must override"
class ZeusConfigurator {

    var store: DataStoreProtocol!
    var modelManager: ModelManagerProtocol!

    init() {
        setup()
    }

    private func setup() {
        setupCoreDataStack()
        setupMapping()
    }

    private func setupCoreDataStack() {
        let model = NSManagedObjectModel.mergedModelFromBundles(nil)!
        store = DataStore(managedObjectModel: model)
        guard let documentsFolderUrl = documentsFolder else { return }
        let storeUrl = documentsFolderUrl.URLByAppendingPathComponent("Store.sqlite")
        do {
            try store.addPersistentStore(withUrl: storeUrl)
            DataStore.sharedInstance = store
            modelManager = ModelManager(baseUrl: baseUrl, store: store)
            ModelManager.sharedInstance = modelManager
        } catch {
            print("Failed to add persistent store: \(error)")
        }
    }

    private func setupMapping() {
        modelManager.map(Character.mapping(store), House.mapping(store)) {
            character, house in
            character == Router.Characters
            house == Router.Houses
        }
    }
}

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


enum Router: RouterProtocol {
    case Characters, Houses
    var method: HTTPMethod {
        let method: HTTPMethod
        switch self {
        case .Houses: fallthrough
        case .Characters:
            method = .GET
        }
        return method
    }
    var path: String {
        let path: String
        switch self {
        case .Characters:
            path = "characters"
        case .Houses:
            path = "houses"
        }
        return path
    }
}