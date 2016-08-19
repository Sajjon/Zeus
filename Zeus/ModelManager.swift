//
//  ModelManager.swift
//  Zeus
//
//  Created by Cyon Alexander (Ext. Netlight) on 19/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData
import Alamofire

public typealias QueryParameters = Dictionary<String, String>
public typealias Done = (Result) -> Void
public typealias MappingClosure = ([MappingProxy]) -> Void

public protocol Mappable {
    static var mapping: MappingProtocol{get}
}

public struct MappingProxy {
    var context: MappingContext
    let mapping: MappingProtocol
}

public func ==(lhs: MappingProxy, rhs: String) -> ResponseDescriptorProtocol {
    let descriptor = ResponseDescriptor(mapping: lhs.mapping, path: rhs)
    lhs.context.add(responseDescriptor: descriptor)
    return descriptor
}

public protocol MappingContextProtocol {
    var responseDescriptors: [ResponseDescriptorProtocol]{get}
    func add(responseDescriptor descriptor: ResponseDescriptorProtocol)
}

public class MappingContext {
    public var responseDescriptors: [ResponseDescriptorProtocol]

    public init() {
        self.responseDescriptors = []
    }

    func add(responseDescriptor descriptor: ResponseDescriptorProtocol) {
        responseDescriptors.append(descriptor)
    }
}

public struct Result {
    let data: AnyObject?
    let error: NSError?
}

public protocol ModelManagerProtocol {
    static var sharedInstance: ModelManagerProtocol!{get set}
    var managedObjectStore: DataStoreProtocol{get}
    var httpClient: Alamofire.Manager{get}
    func map(mappings: [MappingProtocol], closure: MappingClosure)
    func get(atPath path: String, queryParameters params: QueryParameters?, done: Done?)
    func post(model model: AnyObject?, toPath path: String, queryParameters params: QueryParameters?, done: Done?)
}

public class ModelManager: ModelManagerProtocol {
    public static var sharedInstance: ModelManagerProtocol!
    public let managedObjectStore: DataStoreProtocol
    public let httpClient: Alamofire.Manager

    public init(baseUrl: String, store: DataStoreProtocol) {
        self.managedObjectStore = store
        self.httpClient = Alamofire.Manager()
    }

    public func get(atPath path: String, queryParameters params: QueryParameters?, done: Done?) {
        print("get")
    }

    public func post(model model: AnyObject?, toPath path: String, queryParameters params: QueryParameters?, done: Done?) {
        print("post")
    }

    public func map(mappings: [MappingProtocol], closure: MappingClosure) {
        let context = MappingContext()
        closure(mappings.map{ MappingProxy(context: context, mapping: $0) })
    }

    //MARK: Private Methods
    private func addResponseDescriptors(fromContext context: MappingContext) {
        for descriptor in context.responseDescriptors {
            add(responseDescriptor: descriptor)
        }
    }

    private func add(responseDescriptor descriptor: ResponseDescriptorProtocol) {
        print("adding response descriptor")
    }
}

public protocol DataStoreProtocol {
    static var sharedInstance: DataStoreProtocol!{get set}
    var managedObjectModel: NSManagedObjectModel{get}
    var persistentStoreManagedObjectContext: NSManagedObjectContext!{get}
    var mainThreadManagedObjectContext: NSManagedObjectContext!{get}
    var persistentStoreCoordinator: NSPersistentStoreCoordinator!{get}
    func addPersistentStore(atPath storePath: String) throws -> NSPersistentStore
}

public class DataStore: DataStoreProtocol {
    public static var sharedInstance: DataStoreProtocol!
    public private(set) var managedObjectModel: NSManagedObjectModel
    public private(set) var persistentStoreManagedObjectContext: NSManagedObjectContext!
    public private(set) var mainThreadManagedObjectContext: NSManagedObjectContext!
    public private(set) var persistentStoreCoordinator: NSPersistentStoreCoordinator!

    public init(managedObjectModel model: NSManagedObjectModel) {
        self.managedObjectModel = model
        createManagedObjectContext()
    }

    public func addPersistentStore(atPath storePath: String) throws -> NSPersistentStore {
        fatalError()
    }

    //MARK: Private Methods
    private func createManagedObjectContext() {
        persistentStoreManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        persistentStoreManagedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        persistentStoreManagedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy

        mainThreadManagedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        mainThreadManagedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        mainThreadManagedObjectContext.parentContext = persistentStoreManagedObjectContext
        mainThreadManagedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }
}

public enum HTTPMethod {
    case ANY, GET, POST
}

public protocol ResponseDescriptorProtocol {
    var mapping: MappingProtocol{get}
    var method: HTTPMethod{get}
    var path: String{get}
}

public struct ResponseDescriptor: ResponseDescriptorProtocol {

    public let mapping: MappingProtocol
    public let method: HTTPMethod
    public let path: String

    init(mapping: MappingProtocol, method: HTTPMethod = .ANY, path: String) {
        self.mapping = mapping
        self.method = method
        self.path = path
    }
}

public protocol MappingProtocol {
    var entity: NSManagedObject.Type{get}
    var attributeMapping: AttributeMappingProtocol{get}
}

public struct Mapping: MappingProtocol {
    public let entity: NSManagedObject.Type
    public let attributeMapping: AttributeMappingProtocol

    init(entity: NSManagedObject.Type, attributeMapping: AttributeMappingProtocol) {
        self.entity = entity
        self.attributeMapping = attributeMapping
    }

}

public protocol AttributeMappingProtocol {

}

public struct AttributeMapping: AttributeMappingProtocol {

}

public var documentsFolder: NSURL? {
    let fileManager = NSFileManager.defaultManager()
    let path = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last
    return path
}

public var documentsFolderPath: String? {
    return documentsFolder?.absoluteString
}