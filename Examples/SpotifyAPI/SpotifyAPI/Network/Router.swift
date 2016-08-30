//
//  Router.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 23/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import Zeus

let noId = "not_used"
enum Router: RouterProtocol {
    case albumById(String)
    case artistById(String)

    var method: HTTPMethod {
        let method: HTTPMethod
        switch self {
        case .albumById: fallthrough
        case .artistById:
            method = .get
        }
        return method
    }

    var pathMapping: String {
        let path: String
        switch self {

        case .albumById:
            path = "albums/:id"
        case .artistById:
            path = "artist/:id"
        }
        return path
    }

    var path: String {
        let path: String
        switch self {
        case .albumById(let id):
            path = parameterize(path: pathMapping, withParameter: id)
        case .artistById(let id):
            path = parameterize(path: pathMapping, withParameter: id)
        default:
            path = pathMapping
        }
        return path
    }
}

//MARK: Private Methods
private extension Router {

    func parameterize(path: String, withParameters parameters: Any?...) -> String {
        guard parameters.count > 0 else { return path }
        var path = path
        for parameter in parameters {
            let parametrizedString = parameterize(path: path, withParameter: parameter)
            path = parametrizedString
        }
        return path
    }

    func parameterize(path: String, withParameter parameter: Any?) -> String {
        guard let parameter = parameter else { return path }
        do {
            let regex = try NSRegularExpression(pattern: "(:[\\w]*)/*", options: [])
            guard let match = regex.firstMatch(in: path, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, path.length)) else { return path }
            let string = path as NSString
            let parametrizedString = string.replacingCharacters(in: match.rangeAt(1), with: "\(parameter)")
            return parametrizedString
        } catch {
            print("failed to execute regexp")
            return path
        }
    }

}
