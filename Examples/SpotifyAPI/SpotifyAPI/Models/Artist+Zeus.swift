//
//  Artist+Zeus.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 05/09/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import Zeus

extension Artist: MappableEntity {

    class var destinationClass: NSObject.Type {
        return self
    }

    class var idAttributeName: String {
        return "artistId"
    }

    class var attributeMapping: AttributeMappingProtocol {
        return AttributeMapping(mapping: [
            "id": "artistId",
            "name": "name",
            "type": "type",
            "followers.total" : "followersRaw",
            "genres" : "genres",
            "popularity": "popularityRaw"
            ])
    }

    class func relationships(store: DataStoreProtocol) -> [RelationshipMappingProtocol]? {
        let externalUrl = RelationshipMapping(sourceKeyPath: "external_urls", destinationKeyPath: "externalUrl", mapping: ExternalUrl.entityMapping(store))
        let images = RelationshipMapping(sourceKeyPath: "images", destinationKeyPath: "imagesSet", mapping: Image.entityMapping(store))

        return [externalUrl, images]
    }
}
