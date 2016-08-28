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
    func addPersistentStore(withUrl storeUrl: URL) throws -> NSPersistentStore
}

open class DataStore: DataStoreProtocol {
    open static var sharedInstance: DataStoreProtocol!


    open var logLevel: SwiftyBeaver.Level {
        set {
            log.removeDestination(console)
            console = consoleLogging(withLogLevel: newValue)
            log.addDestination(console)
        }
        get {
            return console.minLevel
        }
    }

    open fileprivate(set) var managedObjectModel: NSManagedObjectModel
    open fileprivate(set) var persistentStoreManagedObjectContext: NSManagedObjectContext!
    open fileprivate(set) var mainThreadManagedObjectContext: NSManagedObjectContext!
    open fileprivate(set) var persistentStoreCoordinator: NSPersistentStoreCoordinator!

    fileprivate var console: ConsoleDestination /* Logging by SwiftyBeaver */

    public convenience init() {
        let model = NSManagedObjectModel.mergedModel(from: nil)!
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

    open func addPersistentStore(withUrl storeUrl: URL) throws -> NSPersistentStore {
        let store: NSPersistentStore
        do {
            try store = persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: nil)
        } catch let error {
            log.error("Failed to add SQLite store, error: \(error)")
            throw ZeusError.addingSQLiteStore
        }
        return store
    }
}

public var defaultStoreURL: URL? {
    guard let documentsFolderUrl = documentsFolder else { return nil }
    let storeUrl = documentsFolderUrl.appendingPathComponent("Store.sqlite")
    return storeUrl
}

//MARK: Private Methods
private extension DataStore {
    func tryAddPersistentStore() -> Bool {
        guard let storeUrl = defaultStoreURL else { return false }
        do {
           try addPersistentStore(withUrl: storeUrl)
        } catch {
            log.error("Failed to add persistent store: \(error)")
        }
        log.error("Added SQLite database at: \(storeUrl.absoluteString)")
        return true
    }

    func createManagedObjectContext() {
        persistentStoreManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persistentStoreManagedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        persistentStoreManagedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy

        mainThreadManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainThreadManagedObjectContext.parent = persistentStoreManagedObjectContext
        mainThreadManagedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }
}
