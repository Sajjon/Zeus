//
//  Artist+CoreDataProperties.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 30/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData

extension Artist {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Artist> {
        return NSFetchRequest<Artist>(entityName: "Artist");
    }

    @NSManaged public var artistId: String
    @NSManaged public var name: String
    @NSManaged public var type: String

    @NSManaged public var followersRaw: NSNumber?
    @NSManaged public var popularityRaw: NSNumber?
    @NSManaged public var genres: [String]?

    @NSManaged public var imagesSet: NSSet?
    @NSManaged public var albumsSet: NSSet?

}

// MARK: Generated accessors for imagesSet
extension Artist {

    @objc(addImagesSetObject:)
    @NSManaged public func addToImagesSet(_ value: Image)

    @objc(removeImagesSetObject:)
    @NSManaged public func removeFromImagesSet(_ value: Image)

    @objc(addImagesSet:)
    @NSManaged public func addToImagesSet(_ values: NSSet)

    @objc(removeImagesSet:)
    @NSManaged public func removeFromImagesSet(_ values: NSSet)

}

// MARK: Generated accessors for albumsSet
extension Artist {

    @objc(addAlbumsSetObject:)
    @NSManaged public func addToAlbumsSet(_ value: Album)

    @objc(removeAlbumsSetObject:)
    @NSManaged public func removeFromAlbumsSet(_ value: Album)

    @objc(addAlbumsSet:)
    @NSManaged public func addToAlbumsSet(_ values: NSSet)

    @objc(removeAlbumsSet:)
    @NSManaged public func removeFromAlbumsSet(_ values: NSSet)

}
