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

private let baseUrl = "https://restcountries.eu/rest/v1"
let mustOverride = "must override"
class ZeusConfigurator {

    var store: DataStoreProtocol!
    var modelManager: ModelManagerProtocol!

    init() {
        setup()
    }

    private func setup() {
        setupCoreDataStack()
    }

    private func setupCoreDataStack() {
        let model = NSManagedObjectModel.mergedModelFromBundles(nil)!
        store = DataStore(managedObjectModel: model)
        guard let documentsFolder = documentsFolderPath else { return }
        let path = documentsFolder + "Store.sqlite"
        do {
            try store.addPersistentStore(atPath: path)
            DataStore.sharedInstance = store
            modelManager = ModelManager(baseUrl: baseUrl, store: store)
            ModelManager.sharedInstance = modelManager
        } catch {
            print("Failed to add persistent store: \(error)")
        }
    }

    private func setupMapping() {
        let countryMapping = Country.mapping(store)
        modelManager.map(countryMapping) {
            countryMapping in
            countryMapping == Router.Countries
        }
    }
}


enum Router: RouterProtocol {
    case Countries
    var method: HTTPMethod {
        let method: HTTPMethod
        switch self {
        case .Countries:
            method = .GET
        }
        return method
    }
    var path: String {
        let path: String
        switch self {
        case .Countries:
            path = "countries"
        }
        return path
    }
}