//
//  Album+CoreDataClass.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 30/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData
import Zeus


class Album: ManagedObject {

    override class var idAttributeName: String {
        return "albumId"
    }

    override class var attributeMapping: AttributeMappingProtocol {
        return AttributeMapping(mapping: [
            "id": "albumId",
            "name": "name",
            "available_markets": "availableMarkets",
            "href": "href",
            "uri" : "uri",
            "release_date" : "releaseDate",
            "popularity": "popularityRaw"
            ])
    }

    override class func relationships(store: DataStoreProtocol) -> [RelationshipMappingProtocol]? {
        let images = RelationshipMapping(sourceKeyPath: "images", destinationKeyPath: "imagesSet", mapping: Image.entityMapping(store))
        let tracks = RelationshipMapping(sourceKeyPath: "tracks.items", destinationKeyPath: "tracksOrderedSet", mapping: Track.entityMapping(store))
        return [images, tracks]
    }

    override class var transformers: [TransformerProtocol]? {
        return nil
    }

}

extension Album {

    var artists: [Artist]? {
        return artistsSet?.allObjects as? [Artist]
    }

    var images: [Image]? {
        return imagesSet?.allObjects as? [Image]
    }

    var tracks: [Track]? {
        return tracksOrderedSet?.array as? [Track]
    }

    var releaseDateString: String? {
        guard let date = releaseDate as? Date else { return nil }
        let string = date.shortDate
        return string
    }

    var popularity: Int? {
        return popularityRaw as? Int
    }

}

extension DateFormatter {
    convenience init(dateStyle: DateFormatter.Style) {
        self.init()
        self.dateStyle = dateStyle
    }
}

extension Date {
    struct Formatter {
        static let shortDate = DateFormatter(dateStyle: .short)
    }
    var shortDate: String {
        return Formatter.shortDate.string(from: self)
    }
}
