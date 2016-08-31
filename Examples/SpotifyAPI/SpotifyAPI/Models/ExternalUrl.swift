//
//  ExternalUrl+CoreDataClass.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 31/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData
import Zeus

class ExternalUrl: ManagedObject {

    override class var idAttributeName: String {
        return "spotify"
    }

    override class var attributeMapping: AttributeMappingProtocol {
        return AttributeMapping(mapping: [
            "spotify": "spotify"
        ])
    }
}
