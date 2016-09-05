//
//  ExternalUrl+Zeus.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 05/09/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import Zeus

extension ExternalUrl: MappableEntity {

    class var destinationClass: NSObject.Type {
        return self
    }

    class var idAttributeName: String {
        return "spotify"
    }

    class var attributeMapping: AttributeMappingProtocol {
        return AttributeMapping(mapping: [
            "spotify": "spotify"
            ])
    }
}
