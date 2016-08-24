//
//  House.swift
//  ApiOfIceAndFire
//
//  Created by Alexander Georgii-Hemming Cyon on 20/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData
import Zeus

class House: ManagedObject {
    @NSManaged var name: String?
    @NSManaged var words: String?
    @NSManaged var region: String?
    @NSManaged var coatOfArms: String?
    @NSManaged var membersSet: NSSet?
    @NSManaged var currentLord: Character?

    @NSManaged var memberIds: [String]?

    override class var idAttributeName: String {
        return "name"
    }

    override class var attributeMapping: AttributeMappingProtocol {
        return AttributeMapping(mapping: [
            "name": "name",
            "words": "words",
            "region": "region",
            "coatOfArms": "coatOfArms",
            "swornMembers" : "memberIds"
        ])
    }

    override class var transformers: [TransformerProtocol]? {
        let memberIdTransformer = Transformer(key: "swornMembers") {
            (obj: NSObject?) -> NSObject? in

            guard let urlString = obj as? NSString,
                url = NSURL(string: urlString as String)
                else { return obj}

            let memberId = url.lastPathComponent
            return memberId
        }
        return [memberIdTransformer]
    }

    override class func futureConnections(forMapping mapping: MappingProtocol) -> [FutureConnectionProtocol]? {
        let characterFuture = FutureConnection(relationshipName: "membersSet", mapping: mapping, sourceAttributeName: "memberIds", targetIdAttributeName: "characterId")
        return [characterFuture]
    }
}

extension House {
    var members: [Character]? {
        return membersSet?.allObjects as? [Character]
    }
}