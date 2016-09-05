//
//  Album+Zeus.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 05/09/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import Zeus

extension Album: MappableEntity {

    class var destinationClass: NSObject.Type {
        return self
    }

    class var idAttributeName: String {
        return "albumId"
    }

    class var attributeMapping: AttributeMappingProtocol {
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

    class func relationships(store: DataStoreProtocol) -> [RelationshipMappingProtocol]? {
        let images = RelationshipMapping(sourceKeyPath: "images", destinationKeyPath: "imagesSet", mapping: Image.entityMapping(store))
        let tracks = RelationshipMapping(sourceKeyPath: "tracks.items", destinationKeyPath: "tracksOrderedSet", mapping: Track.entityMapping(store))
        return [images, tracks]
    }
}
