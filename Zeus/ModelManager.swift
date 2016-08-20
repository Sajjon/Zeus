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
public typealias JSONMapping = Dictionary<String, String>
public typealias Done = (Result) -> Void

public struct MappingProxy {
    var context: MappingContext
    let mapping: MappingProtocol
}

public func ==(lhs: MappingProxy, rhs: RouterProtocol) -> ResponseDescriptorProtocol {
    let descriptor = ResponseDescriptor(mapping: lhs.mapping, route: rhs)
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
    func map(a: MappingProtocol, closure: (MappingProxy) -> Void)
    func map(a: MappingProtocol, _ b: MappingProtocol, closure: (MappingProxy, MappingProxy) -> Void)
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

    public func map(a: MappingProtocol, closure: (MappingProxy) -> Void) {
        let context = MappingContext()
        closure(
            MappingProxy(context: context, mapping: a)
        )
    }

    public func map(a: MappingProtocol, _ b: MappingProtocol, closure: (MappingProxy, MappingProxy) -> Void) {
        let context = MappingContext()
        closure(
            MappingProxy(context: context, mapping: a),
            MappingProxy(context: context, mapping: b)
        )
    }

//    public func map(mappings: [MappingProtocol], closure: MappingClosure) {
//        let context = MappingContext()
//        closure(mappings.map{ MappingProxy(context: context, mapping: $0) })
//    }

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

public protocol RouterProtocol {
    var method: HTTPMethod{get}
    var path: String{get}
}

public protocol ResponseDescriptorProtocol {
    var mapping: MappingProtocol{get}
    var route: RouterProtocol{get}
}

public struct ResponseDescriptor: ResponseDescriptorProtocol {

    public let mapping: MappingProtocol
    public let route: RouterProtocol

    public init(mapping: MappingProtocol, route: RouterProtocol) {
        self.mapping = mapping
        self.route = route
    }
}

public protocol MappingProtocol {
    var managedObjectContext: NSManagedObjectContext{get}
    var entity: NSManagedObject.Type{get}
    var idAttributeName: String{get}
    var attributeMapping: AttributeMappingProtocol{get}
}

public struct Mapping: MappingProtocol {
    public let managedObjectContext: NSManagedObjectContext
    public let entity: NSManagedObject.Type
    public let idAttributeName: String
    public let attributeMapping: AttributeMappingProtocol

    public init(managedObjectContext: NSManagedObjectContext, entity: NSManagedObject.Type, idAttributeName: String, attributeMapping: AttributeMappingProtocol) {
        self.managedObjectContext = managedObjectContext
        self.entity = entity
        self.idAttributeName = idAttributeName
        self.attributeMapping = attributeMapping
    }
}

public protocol AttributeMappingProtocol {
    var mapping: JSONMapping{get}
}

public struct AttributeMapping: AttributeMappingProtocol {
    public let mapping: JSONMapping
    public init(mapping: JSONMapping) {
        self.mapping = mapping
    }
}

public protocol Mappable {
    static var entity: NSManagedObject.Type{get}
    static var idAttributeName: String{get}
    static var attributeMapping: AttributeMappingProtocol{get}
    static func mapping(store: DataStoreProtocol) -> MappingProtocol
}

public extension Mappable {
    static func mapping(store: DataStoreProtocol) -> MappingProtocol {
        let moc = store.persistentStoreManagedObjectContext
        let mapping = Mapping(managedObjectContext: moc, entity: entity, idAttributeName: idAttributeName, attributeMapping: attributeMapping)
        return mapping
    }
}

public var documentsFolder: NSURL? {
    let fileManager = NSFileManager.defaultManager()
    let path = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last
    return path
}

public var documentsFolderPath: String? {
    return documentsFolder?.absoluteString
}