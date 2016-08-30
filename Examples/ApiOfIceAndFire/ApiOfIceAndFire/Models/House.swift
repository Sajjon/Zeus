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
    @NSManaged var houseId: String
    @NSManaged var name: String
    @NSManaged var words: String
    @NSManaged var region: String
    @NSManaged var coatOfArms: String
    @NSManaged var membersSet: NSSet?
    @NSManaged var cadetBranchesSet: NSSet?
    @NSManaged var currentLord: Character?

    @NSManaged var memberIds: [String]
    @NSManaged var cadetBranchIds: [String]

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
        let houseIdTransformer = URLToIdTransformer(key: "url")
        let memberIdTransformer = URLToIdTransformer(key: "swornMembers")
        let cadetBranchIdTransformer = URLToIdTransformer(key: "cadetBranches")
        return [houseIdTransformer, memberIdTransformer, cadetBranchIdTransformer]
    }

    override class var shouldStoreModelCondtions: [ShouldStoreModelConditionProtocol]? {
        let noBoltonsAllowed = StoreModelConditionString(attributeName: "name") {
            (name: String, maybeCurrentValue: String?) -> Bool in
            let isBolton = name.contains("Bolton")
            if isBolton {
                print("We don't like the Boltons, they are not invited into our app! Skipping mapping...")
            }
            return !isBolton
        }
        return [noBoltonsAllowed]
    }

    override class var cherryPickers: [CherryPickerProtocol]? {
        let picker = CherryPicker(attributeName: "name") {
            (incomingValue: Attribute, currentValue: Attribute) -> Attribute in
            if incomingValue != currentValue {
                print("House changed name from: '\(currentValue)' to '\(incomingValue)'")
            }
            return incomingValue
        }
        return [picker]
    }

//    override class func futureConnections(forMapping mapping: MappingProtocol) -> [FutureConnectionProtocol]? {
//        guard let entityMapping = mapping as? EntityMappingProtocol else { return nil }
//        let characterFuture = FutureEntityConnection(relationshipName: "membersSet", entityMapping: entityMapping, sourceAttributeName: "memberIds", destinationAttributeName: "characterId")
//        let cadetBranchFuture = FutureEntityConnection(relationshipName: "cadetBranchesSet", entityMapping: entityMapping, sourceAttributeName: "cadetBranchIds", destinationAttributeName: "houseId")
//        return [characterFuture, cadetBranchFuture]
//    }
}

extension House {
    var members: [Character]? {
        return membersSet?.allObjects as? [Character]
    }

    var cadetBranches: [House]? {
        return cadetBranchesSet?.allObjects as? [House]
    }
}
