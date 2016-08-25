//
//  ModelManager.swift
//  Zeus
//
//  Created by Alexander Georgii-Hemming Cyon on 20/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData
import Alamofire
import SwiftyBeaver

public protocol ModelManagerProtocol {
    static var sharedInstance: ModelManagerProtocol!{get set}
    var managedObjectStore: DataStoreProtocol{get}
    var httpClient: Alamofire.Manager{get}
    func map(a: MappingProtocol, closure: (MappingProxy) -> Void)
    func map(a: MappingProtocol, _ b: MappingProtocol, closure: (MappingProxy, MappingProxy) -> Void)
    func map(a: MappingProtocol, _ b: MappingProtocol, _ c: MappingProtocol, closure: (MappingProxy, MappingProxy, MappingProxy) -> Void)
    func map(a: MappingProtocol, _ b: MappingProtocol, _ c: MappingProtocol, _ d: MappingProtocol, closure: (MappingProxy, MappingProxy, MappingProxy, MappingProxy) -> Void)
    func map(a: MappingProtocol, _ b: MappingProtocol, _ c: MappingProtocol, _ d: MappingProtocol, _ e: MappingProtocol, closure: (MappingProxy, MappingProxy, MappingProxy, MappingProxy, MappingProxy) -> Void)
    func get(atPath path: String, queryParameters params: QueryParameters?, done: Done?)
    func post(model model: AnyObject?, toPath path: String, queryParameters params: QueryParameters?, done: Done?)
}

public class ModelManager: ModelManagerProtocol {

    public static var sharedInstance: ModelManagerProtocol!
    public let managedObjectStore: DataStoreProtocol
    public let httpClient: Alamofire.Manager

    private let modelMappingManager: ModelMappingManagerProtocol
    private let baseUrl: String

    public init(baseUrl: String, store: DataStoreProtocol) {
        self.baseUrl = baseUrl
        self.managedObjectStore = store
        self.httpClient = Alamofire.Manager()
        self.modelMappingManager = ModelMappingManager()
    }

    public func get(atPath path: String, queryParameters params: QueryParameters?, done: Done?) {
        let pathFull = fullPath(withPath: path)
        httpClient.request(.GET, pathFull, parameters: params)
            .validate()
            .responseJSON() {
                response in
                self.handle(jsonResponse: response, fromPath: path, done: done)
        }
    }

    public func post(model model: AnyObject?, toPath path: String, queryParameters params: QueryParameters?, done: Done?) {
        log.error("post")
    }

    public func map(
        a: MappingProtocol,
        closure: (MappingProxy) -> Void
        ) {
        let context = MappingContext()
        closure(
            MappingProxy(context: context, mapping: a)
        )
        modelMappingManager.addResponseDescriptors(fromContext: context)
    }

    public func map(
        a: MappingProtocol,
        _ b: MappingProtocol,
          closure: (MappingProxy, MappingProxy) -> Void
        ) {
        let context = MappingContext()
        closure(
            MappingProxy(context: context, mapping: a),
            MappingProxy(context: context, mapping: b)
        )
        modelMappingManager.addResponseDescriptors(fromContext: context)
    }


    public func map(
        a: MappingProtocol,
        _ b: MappingProtocol,
          _ c: MappingProtocol,
            closure: (MappingProxy, MappingProxy, MappingProxy) -> Void
        ) {
        let context = MappingContext()
        closure(
            MappingProxy(context: context, mapping: a),
            MappingProxy(context: context, mapping: b),
            MappingProxy(context: context, mapping: c)
        )
        modelMappingManager.addResponseDescriptors(fromContext: context)
    }

    public func map(
        a: MappingProtocol,
        _ b: MappingProtocol,
          _ c: MappingProtocol,
            _ d: MappingProtocol,
              closure: (MappingProxy, MappingProxy, MappingProxy, MappingProxy) -> Void
        ) {
        let context = MappingContext()
        closure(
            MappingProxy(context: context, mapping: a),
            MappingProxy(context: context, mapping: b),
            MappingProxy(context: context, mapping: c),
            MappingProxy(context: context, mapping: d)
        )
        modelMappingManager.addResponseDescriptors(fromContext: context)
    }

    public func map(
        a: MappingProtocol,
        _ b: MappingProtocol,
          _ c: MappingProtocol,
            _ d: MappingProtocol,
              _ e: MappingProtocol,
                closure: (MappingProxy, MappingProxy, MappingProxy, MappingProxy, MappingProxy) -> Void
        ) {
        let context = MappingContext()
        closure(
            MappingProxy(context: context, mapping: a),
            MappingProxy(context: context, mapping: b),
            MappingProxy(context: context, mapping: c),
            MappingProxy(context: context, mapping: d),
            MappingProxy(context: context, mapping: e)
        )
        modelMappingManager.addResponseDescriptors(fromContext: context)
    }
}

//MARK: Private Methods
private extension ModelManager {
    private func fullPath(withPath path: String) -> String {
        let fullPath = baseUrl + path
        return fullPath
    }

    private func handle(jsonResponse response: Response<AnyObject, NSError>, fromPath path: String, done: Done?) {
        switch response.result {
        case .Success(let data):
            var result: Result!
            if let jsonArray = data as? [JSON] {
                result = modelMappingManager.mapping(withJsonArray: jsonArray, fromPath: path)
            } else if let json = data as? JSON {
                result = modelMappingManager.mapping(withJson: json, fromPath: path)
            }
            if let mappingResult = result {
                done?(mappingResult)
            } else {
                done?(Result(.ParsingJSON))
            }
        case .Failure(let error):
            log.error("failed, error: \(error)")
            done?(Result(.ParsingJSON))
        }
    }

    private func addResponseDescriptors(fromContext context: MappingContext) {
        modelMappingManager.addResponseDescriptors(fromContext: context)
    }

}