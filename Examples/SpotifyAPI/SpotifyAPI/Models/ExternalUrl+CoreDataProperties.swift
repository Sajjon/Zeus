//
//  ExternalUrl+CoreDataProperties.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 31/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData

extension ExternalUrl {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExternalUrl> {
        return NSFetchRequest<ExternalUrl>(entityName: "ExternalUrl");
    }

    @NSManaged public var spotify: String

    @NSManaged public var artist: Artist

}
