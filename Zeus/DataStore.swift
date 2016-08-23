//
//  DataStore.swift
//  Zeus
//
//  Created by Cyon Alexander on 22/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData
import SwiftyBeaver

public protocol DataStoreProtocol {
    static var sharedInstance: DataStoreProtocol!{get set}
    var logLevel: SwiftyBeaver.Level {get set}
    var managedObjectModel: NSManagedObjectModel{get}
    var persistentStoreManagedObjectContext: NSManagedObjectContext!{get}
    var mainThreadManagedObjectContext: NSManagedObjectContext!{get}
    var persistentStoreCoordinator: NSPersistentStoreCoordinator!{get}
    func addPersistentStore(withUrl storeUrl: NSURL) throws -> NSPersistentStore
}

public class DataStore: DataStoreProtocol {
    public static var sharedInstance: DataStoreProtocol!


    public var logLevel: SwiftyBeaver.Level {
        set {
            log.removeDestination(console)
            console = consoleLogging(withLogLevel: newValue)
            log.addDestination(console)
        }
        get {
            return console.minLevel
        }
    }

    public private(set) var managedObjectModel: NSManagedObjectModel
    public private(set) var persistentStoreManagedObjectContext: NSManagedObjectContext!
    public private(set) var mainThreadManagedObjectContext: NSManagedObjectContext!
    public private(set) var persistentStoreCoordinator: NSPersistentStoreCoordinator!

    private var console: ConsoleDestination /* Logging by SwiftyBeaver */

    public convenience init() {
        let model = NSManagedObjectModel.mergedModelFromBundles(nil)!
        self.init(managedObjectModel: model)
    }

    public init(managedObjectModel model: NSManagedObjectModel) {
        self.managedObjectModel = model
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)

        console = consoleLogging(withLogLevel: .Warning)
        log.addDestination(console)
        log.addDestination(onlineLogging())

        createManagedObjectContext()
        guard tryAddPersistentStore() else { let err = "Failed to add persistent store"; log.error(err); fatalError(err) }
    }

    public func addPersistentStore(withUrl storeUrl: NSURL) throws -> NSPersistentStore {
        let store: NSPersistentStore
        do {
            try store = persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeUrl, options: nil)
        } catch let error {
            log.error("Failed to add SQLite store, error: \(error)")
            throw Error.AddingSQLiteStore
        }
        return store
    }
}

public var defaultStoreURL: NSURL? {
    guard let documentsFolderUrl = documentsFolder else { return nil }
    let storeUrl = documentsFolderUrl.URLByAppendingPathComponent("Store.sqlite")
    return storeUrl
}

//MARK: Private Methods
private extension DataStore {
    private func tryAddPersistentStore() -> Bool {
        guard let storeUrl = defaultStoreURL else { return false }
        do {
           try addPersistentStore(withUrl: storeUrl)
        } catch {
            log.error("Failed to add persistent store: \(error)")
        }
        log.error("Added SQLite database at: \(storeUrl.absoluteString)")
        return true
    }

    private func createManagedObjectContext() {
        persistentStoreManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        persistentStoreManagedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        persistentStoreManagedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy

        mainThreadManagedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        mainThreadManagedObjectContext.parentContext = persistentStoreManagedObjectContext
        mainThreadManagedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }
}