//
//  Track+CoreDataProperties.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 30/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData

extension Track {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Track> {
        return NSFetchRequest<Track>(entityName: "Track");
    }

    @NSManaged public var trackId: String
    @NSManaged public var name: String
    @NSManaged public var discNumberRaw: Int16
    @NSManaged public var durationMsRaw: Int32
    @NSManaged public var trackNumberRaw: Int16
    @NSManaged public var uri: String
    @NSManaged public var href: String
    @NSManaged public var streamUrl: String

    @NSManaged public var album: Album?

}
