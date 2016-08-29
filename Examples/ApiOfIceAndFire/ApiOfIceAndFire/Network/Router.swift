//
//  Router.swift
//  ApiOfIceAndFire
//
//  Created by Cyon Alexander (Ext. Netlight) on 23/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import Zeus

enum Router: RouterProtocol {
    case characters
    case characterById(String!)
    case houses
    case houseById(String!)

    var method: HTTPMethod {
        let method: HTTPMethod
        switch self {
        case .houses: fallthrough
        case .houseById: fallthrough
        case .characters: fallthrough
        case .characterById:
            method = .get
        }
        return method
    }

    var pathMapping: String {
        let path: String
        switch self {
        case .characters:
            path = "characters"
        case .characterById:
            path = "\(Router.characters.pathMapping)/:id"
        case .houses:
            path = "houses"
        case .houseById:
            path = "\(Router.houses.pathMapping)/:id"
        }
        return path
    }

    var path: String {
        let path: String
        switch self {
        case .houseById(let id):
            path = "\(Router.houses.pathMapping)/\(id!)"
        case .characterById(let id):
            path = "\(Router.characters.pathMapping)/\(id!)"
        default:
            path = pathMapping
        }
        return path
    }
}
