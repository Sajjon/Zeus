//
//  Track+Zeus.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 05/09/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import Zeus

extension Track: MappableEntity {

    class var destinationClass: NSObject.Type {
        return self
    }

    class var idAttributeName: String {
        return "trackId"
    }

    class var attributeMapping: AttributeMappingProtocol {
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
}
