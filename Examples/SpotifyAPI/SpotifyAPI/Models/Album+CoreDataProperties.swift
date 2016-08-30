//
//  Album+CoreDataProperties.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 30/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData

extension Album {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Album> {
        return NSFetchRequest<Album>(entityName: "Album");
    }

    @NSManaged public var name: String
    @NSManaged public var availableMarkets: [String]
    @NSManaged public var albumId: String
    @NSManaged public var uri: String
    @NSManaged public var href: String

    // Optional
    @NSManaged public var popularityRaw: NSNumber?
    @NSManaged public var releaseDate: NSDate?

    // Relationships
    @NSManaged public var artistsSet: NSSet?
    @NSManaged public var imagesSet: NSSet?
    @NSManaged public var tracksOrderedSet: NSOrderedSet?

}

// MARK: Generated accessors for artistsSet
extension Album {

    @objc(addArtistsSetObject:)
    @NSManaged public func addToArtistsSet(_ value: Artist)

    @objc(removeArtistsSetObject:)
    @NSManaged public func removeFromArtistsSet(_ value: Artist)

    @objc(addArtistsSet:)
    @NSManaged public func addToArtistsSet(_ values: NSSet)

    @objc(removeArtistsSet:)
    @NSManaged public func removeFromArtistsSet(_ values: NSSet)

}

// MARK: Generated accessors for imagesSet
extension Album {

    @objc(addImagesSetObject:)
    @NSManaged public func addToImagesSet(_ value: Image)

    @objc(removeImagesSetObject:)
    @NSManaged public func removeFromImagesSet(_ value: Image)

    @objc(addImagesSet:)
    @NSManaged public func addToImagesSet(_ values: NSSet)

    @objc(removeImagesSet:)
    @NSManaged public func removeFromImagesSet(_ values: NSSet)

}

// MARK: Generated accessors for tracksOrderedSet
extension Album {

    @objc(insertObject:inTracksOrderedSetAtIndex:)
    @NSManaged public func insertIntoTracksOrderedSet(_ value: Track, at idx: Int)

    @objc(removeObjectFromTracksOrderedSetAtIndex:)
    @NSManaged public func removeFromTracksOrderedSet(at idx: Int)

    @objc(insertTracksOrderedSet:atIndexes:)
    @NSManaged public func insertIntoTracksOrderedSet(_ values: [Track], at indexes: NSIndexSet)

    @objc(removeTracksOrderedSetAtIndexes:)
    @NSManaged public func removeFromTracksOrderedSet(at indexes: NSIndexSet)

    @objc(replaceObjectInTracksOrderedSetAtIndex:withObject:)
    @NSManaged public func replaceTracksOrderedSet(at idx: Int, with value: Track)

    @objc(replaceTracksOrderedSetAtIndexes:withTracksOrderedSet:)
    @NSManaged public func replaceTracksOrderedSet(at indexes: NSIndexSet, with values: [Track])

    @objc(addTracksOrderedSetObject:)
    @NSManaged public func addToTracksOrderedSet(_ value: Track)

    @objc(removeTracksOrderedSetObject:)
    @NSManaged public func removeFromTracksOrderedSet(_ value: Track)

    @objc(addTracksOrderedSet:)
    @NSManaged public func addToTracksOrderedSet(_ values: NSOrderedSet)

    @objc(removeTracksOrderedSet:)
    @NSManaged public func removeFromTracksOrderedSet(_ values: NSOrderedSet)

}
