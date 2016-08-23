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
    case Characters, Houses
    var method: HTTPMethod {
        let method: HTTPMethod
        switch self {
        case .Houses: fallthrough
        case .Characters:
            method = .GET
        }
        return method
    }
    var path: String {
        let path: String
        switch self {
        case .Characters:
            path = "characters"
        case .Houses:
            path = "houses"
        }
        return path
    }
}