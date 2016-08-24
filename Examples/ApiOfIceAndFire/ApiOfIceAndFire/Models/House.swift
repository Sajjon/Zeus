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
    @NSManaged var houseId: String?
    @NSManaged var name: String?
    @NSManaged var words: String?
    @NSManaged var region: String?
    @NSManaged var coatOfArms: String?
    @NSManaged var membersSet: NSSet?
    @NSManaged var cadetBranchesSet: NSSet?
    @NSManaged var currentLord: Character?

    @NSManaged var memberIds: [String]?
    @NSManaged var cadetBranchIds: [String]?

    override class var idAttributeName: String {
        return "houseId"
    }

    override class var attributeMapping: AttributeMappingProtocol {
        return AttributeMapping(mapping: [
            "url": "houseId",
            "name": "name",
            "words": "words",
            "region": "region",
            "coatOfArms": "coatOfArms",
            "swornMembers" : "memberIds",
            "cadetBranches" : "cadetBranchIds"
        ])
    }

    override class var transformers: [TransformerProtocol]? {
        let houseIdTransformer = Transformer(key: "url") {
            (obj: NSObject?) -> NSObject? in

            guard let urlString = obj as? NSString,
                url = NSURL(string: urlString as String)
                else { return obj}

            let houseId = url.lastPathComponent
            return houseId
        }
        let memberIdTransformer = Transformer(key: "swornMembers") {
            (obj: NSObject?) -> NSObject? in

            guard let urlString = obj as? NSString,
                url = NSURL(string: urlString as String)
                else { return obj}

            let memberId = url.lastPathComponent
            return memberId
        }
        let cadetBranchIdTransformer = Transformer(key: "cadetBranches") {
            (obj: NSObject?) -> NSObject? in

            guard let urlString = obj as? NSString,
                url = NSURL(string: urlString as String)
                else { return obj}

            let branchId = url.lastPathComponent
            return branchId
        }
        return [houseIdTransformer, memberIdTransformer, cadetBranchIdTransformer]
    }

    override class func futureConnections(forMapping mapping: MappingProtocol) -> [FutureConnectionProtocol]? {
        let characterFuture = FutureConnection(relationshipName: "membersSet", mapping: mapping, sourceAttributeName: "memberIds", targetIdAttributeName: "characterId")
        let cadetBranchFuture = FutureConnection(relationshipName: "cadetBranchesSet", mapping: mapping, sourceAttributeName: "cadetBranchIds", targetIdAttributeName: "houseId")
        return [characterFuture, cadetBranchFuture]
    }
}

extension House {
    var members: [Character]? {
        return membersSet?.allObjects as? [Character]
    }

    var cadetBranches: [House]? {
        return cadetBranchesSet?.allObjects as? [House]
    }
}