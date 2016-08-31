//
//  Artist+CoreDataClass.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 30/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData
import Zeus

class Artist: ManagedObject {


    override class var idAttributeName: String {
        return "artistId"
    }

    override class var attributeMapping: AttributeMappingProtocol {
        return AttributeMapping(mapping: [
            "id": "artistId",
            "name": "name",
            "type": "type",
            "followers.total" : "followersRaw",
            "genres" : "genres",
            "popularity": "popularityRaw"
            ])
    }

    override class func relationships(store: DataStoreProtocol) -> [RelationshipMappingProtocol]? {
        let externalUrl = RelationshipMapping(sourceKeyPath: "external_urls", destinationKeyPath: "externalUrl", mapping: ExternalUrl.entityMapping(store))
        let images = RelationshipMapping(sourceKeyPath: "images", destinationKeyPath: "imagesSet", mapping: Image.entityMapping(store))

        return [externalUrl, images]
    }
}

extension Artist {
    var popularity: Int? {
        return popularityRaw as? Int
    }

    var followers: Int? {
        return followersRaw as? Int
    }

    var images: [Image]? {
        return imagesSet?.allObjects as? [Image]
    }

    var albums: [Album]? {
        get {
            return albumsSet?.allObjects as? [Album]
        }

        set(maybeAlbums) {
            guard let newAlbums = maybeAlbums else { return }
            albumsSet = NSSet(array: newAlbums)
        }
    }
}
