//
//  Country.swift
//  ApiOfIceAndFire
//
//  Created by Alexander Georgii-Hemming Cyon on 20/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData
import Zeus

class Character: ManagedObject {
    @NSManaged var characterId: String?
    @NSManaged var name: String?
    @NSManaged var gender: String?
    @NSManaged var house: House?
    @NSManaged var lordOfHouses: NSSet?

    override class var idAttributeName: String {
        return "characterId"
    }

    override class var attributeMapping: AttributeMappingProtocol {
        return AttributeMapping(mapping: [
            "url" : "characterId",
            "name": "name",
            "gender": "gender"
        ])
    }

    override class var transformers: [TransformerProtocol]? {
        let characterIdTransformer = Transformer(key: "url") {
            (obj: NSObject?) -> NSObject? in

            guard let urlString = obj as? NSString,
                url = NSURL(string: urlString as String)
                else { return obj}

            let characterId = url.lastPathComponent
            return characterId
        }
        return [characterIdTransformer]
    }
}