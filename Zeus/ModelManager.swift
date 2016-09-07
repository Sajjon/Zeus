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

fileprivate typealias BackendResponse = Alamofire.Response<Any, NSError>

public protocol ModelManagerProtocol {
    static var sharedInstance: ModelManagerProtocol! { get set }
    var managedObjectStore: DataStoreProtocol { get }
    var httpClient: Alamofire.SessionManager { get }
    func map(_ a: MappingProtocol, closure: (MappingProxy) -> Void)
    func map(_ a: MappingProtocol, _ b: MappingProtocol, closure: (MappingProxy, MappingProxy) -> Void)
    func map(_ a: MappingProtocol, _ b: MappingProtocol, _ c: MappingProtocol, closure: (MappingProxy, MappingProxy, MappingProxy) -> Void)
    func map(_ a: MappingProtocol, _ b: MappingProtocol, _ c: MappingProtocol, _ d: MappingProtocol, closure: (MappingProxy, MappingProxy, MappingProxy, MappingProxy) -> Void)
    func map(_ a: MappingProtocol, _ b: MappingProtocol, _ c: MappingProtocol, _ d: MappingProtocol, _ e: MappingProtocol, closure: (MappingProxy, MappingProxy, MappingProxy, MappingProxy, MappingProxy) -> Void)
    func get(atPath path: APIPathProtocol, queryParameters params: QueryParameters?, options: Options?, done: Done?)
    func post(model: AnyObject?, toPath path: APIPathProtocol, queryParameters params: QueryParameters?, done: Done?)
}

open class ModelManager: ModelManagerProtocol {

    open static var sharedInstance: ModelManagerProtocol!
    open let managedObjectStore: DataStoreProtocol
    open let httpClient: Alamofire.SessionManager

    fileprivate let modelMappingManager: ModelMappingManagerProtocol
    fileprivate let baseUrl: String

    public init(baseUrl: String, store: DataStoreProtocol) {
        self.baseUrl = baseUrl
        self.managedObjectStore = store
        self.httpClient = Alamofire.SessionManager()
        self.modelMappingManager = ModelMappingManager()
    }

    open func get(atPath path: APIPathProtocol, queryParameters params: QueryParameters?, options: Options?, done: Done?) {
        let pathFull = path.request(baseUrl: baseUrl)
        let options = options ?? Options(.persistEntitiesDuringMapping)

        httpClient.request(pathFull, withMethod: Alamofire.HTTPMethod.get, parameters: params)
            .validate()
            .responseJSON {
                (response: BackendResponse) in
            self.handle(response: response, fromPath: path, options: options, done: done)
        }
    }

    open func post(model: AnyObject?, toPath path: APIPathProtocol, queryParameters params: QueryParameters?, done: Done?) {
        log.error("post")
    }

    open func map(
        _ a: MappingProtocol,
        closure: (MappingProxy) -> Void
        ) {
        let context = MappingContext()
        closure(
            MappingProxy(context: context, mapping: a)
        )
        modelMappingManager.addResponseDescriptors(fromContext: context)
    }

    open func map(
        _ a: MappingProtocol,
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


    open func map(
        _ a: MappingProtocol,
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

    open func map(
        _ a: MappingProtocol,
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

    open func map(
        _ a: MappingProtocol,
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
    func fullPath(withPath path: String) -> String {
        let fullPath = baseUrl + path
        return fullPath
    }

    func handle(response: BackendResponse, fromPath path: APIPathProtocol, options: Options, done: Done?) {
        switch response.result {
        case .success(let result):
            handle(result: result, fromPath: path, options: options, done: done)
        case .failure(let error):
            log.error("failed, error: \(error)")
            done?(Result(.parsingJSON))
        }
    }

    func handle(result: Any, fromPath path: APIPathProtocol, options: Options, done: Done?) {
        guard let json = jsonFrom(result: result) else {
            done?(Result(.parsingJSON))
            return
        }
        let payload: PayloadProtocol = Payload(json: json, path: path, options: options)
        let modelMappingResult = modelMappingManager.model(from: payload)
        persistResultIfNeeded(modelMappingResult, options: options)
        done?(modelMappingResult)
    }

    func jsonFrom(result: Any) -> JSON? {
        var json: JSON?
        if let arrayOrRawJson = result as? [RawJSON] {
            let jsonArray: [JSONObject] = arrayOrRawJson.map { return JSONObject($0) }
            json = JSON.array(jsonArray)
        } else if let singleJsonObject = result as? RawJSON {
            let jsonObject = JSONObject(singleJsonObject)
            json = JSON.object(jsonObject)
        }
        return json
    }

    func addResponseDescriptors(fromContext context: MappingContext) {
        modelMappingManager.addResponseDescriptors(fromContext: context)
    }

    func persistResultIfNeeded(_ result: Result, options: Options) {
        guard result.isSuccess, result.isManagedObject, options.persistEntities else { return }
        managedObjectStore.mainThreadManagedObjectContext.saveToPersistentStore()
    }
}
