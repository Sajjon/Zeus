//
//  Track+CoreDataClass.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 30/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData
import Zeus


class Track: ManagedObject {

    override class var idAttributeName: String {
        return "trackId"
    }

    override class var attributeMapping: AttributeMappingProtocol {
        return AttributeMapping(mapping: [
            "id": "trackId",
            "name": "name",
            "disc_number": "discNumberRaw",
            "duration_ms" : "durationMsRaw",
            "track_number" : "trackNumberRaw",
            "uri": "uri",
            "href": "href",
            "preview_url": "streamUrl"
            ])
    }

    override class var transformers: [TransformerProtocol]? {
        return nil
    }
}
