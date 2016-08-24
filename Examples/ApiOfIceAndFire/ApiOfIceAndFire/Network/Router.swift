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
    case Characters
    case CharacterById(String!)
    case Houses
    var method: HTTPMethod {
        let method: HTTPMethod
        switch self {
        case .Houses: fallthrough
        case .Characters: fallthrough
        case .CharacterById:
            method = .GET
        }
        return method
    }

    var pathMapping: String {
        let path: String
        switch self {
        case .Characters:
            path = "characters"
        case .CharacterById:
            path = "\(Characters.pathMapping)/:id"
        case .Houses:
            path = "houses"
        }
        return path
    }

    var path: String {
        let path: String
        switch self {
        case .CharacterById(let id):
            path = "\(Characters.pathMapping)/\(id)"
        default:
            path = pathMapping
        }
        return path
    }
}