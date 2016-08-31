//
//  Image+CoreDataClass.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 30/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData
import Zeus

class Image: ManagedObject {

    override class var idAttributeName: String {
        return "url"
    }

    override class var attributeMapping: AttributeMappingProtocol {
        return AttributeMapping(mapping: [
            "url": "url",
            "width": "widthRaw",
            "height": "heightRaw"
            ])
    }
}

extension Image {
    var width: Int {
        return Int(widthRaw)
    }

    var height: Int {
        return Int(heightRaw)
    }
}
