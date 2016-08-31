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
enum APIPath: APIPathProtocol {
    case albumById(String)
    case albumsByArtist(String)
    case artistById(String)

    var method: HTTPMethod {
        let method: HTTPMethod
        switch self {
        case .albumById: fallthrough
        case .albumsByArtist: fallthrough
        case .artistById:
            method = .get
        }
        return method
    }

    var mapping: String {
        let path: String
        switch self {

        case .albumById:
            path = "albums/:id"
        case .artistById:
            path = "artists/:id"
        case .albumsByArtist:
            path = "artists/:id/albums"
        }
        return path
    }

    func request(baseUrl: String) -> String {
        let path: String
        switch self {
        case .albumById(let id):
            path = parameterize(path: mapping, withParameter: id)
        case .albumsByArtist(let id):
            path = parameterize(path: mapping, withParameter: id)
        case .artistById(let id):
            path = parameterize(path: mapping, withParameter: id)
        default:
            path = mapping
        }
        let fullPath = baseUrl + path
        return fullPath
    }
}

//MARK: Private Methods
private extension APIPath {

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
