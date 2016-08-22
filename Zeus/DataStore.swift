//
//  DataStore.swift
//  Zeus
//
//  Created by Cyon Alexander (Ext. Netlight) on 22/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData

public protocol DataStoreProtocol {
    static var sharedInstance: DataStoreProtocol!{get set}
    var managedObjectModel: NSManagedObjectModel{get}
    var persistentStoreManagedObjectContext: NSManagedObjectContext!{get}
    var mainThreadManagedObjectContext: NSManagedObjectContext!{get}
    var persistentStoreCoordinator: NSPersistentStoreCoordinator!{get}
    func addPersistentStore(withUrl storeUrl: NSURL) throws -> NSPersistentStore
}

public class DataStore: DataStoreProtocol {
    public static var sharedInstance: DataStoreProtocol!
    public private(set) var managedObjectModel: NSManagedObjectModel
    public private(set) var persistentStoreManagedObjectContext: NSManagedObjectContext!
    public private(set) var mainThreadManagedObjectContext: NSManagedObjectContext!
    public private(set) var persistentStoreCoordinator: NSPersistentStoreCoordinator!

    public init(managedObjectModel model: NSManagedObjectModel) {
        self.managedObjectModel = model
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        createManagedObjectContext()
    }

    public func addPersistentStore(withUrl storeUrl: NSURL) throws -> NSPersistentStore {
        let store: NSPersistentStore
        do {
            try store = persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeUrl, options: nil)
        } catch let error {
            print("Failed to add SQLite store, error: \(error)")
            throw Error.AddingSQLiteStore
        }
        return store
    }

    //MARK: Private Methods
    private func createManagedObjectContext() {
        persistentStoreManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        persistentStoreManagedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        persistentStoreManagedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy

        mainThreadManagedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        mainThreadManagedObjectContext.parentContext = persistentStoreManagedObjectContext
        mainThreadManagedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }
}