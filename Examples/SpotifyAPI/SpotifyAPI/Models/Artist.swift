//
//  Artist+CoreDataClass.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 30/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData

class Artist: NSManagedObject {}

extension Artist {
    var popularity: Int? {
        return popularityRaw as? Int
    }

    var followers: Int? {
        return followersRaw as? Int
    }

    var images: [Image]? {
        return imagesSet?.allObjects as? [Image]
    }

    var albums: [Album]? {
        get {
            return albumsSet?.allObjects as? [Album]
        }

        set(maybeAlbums) {
            guard let newAlbums = maybeAlbums else { return }
            albumsSet = NSSet(array: newAlbums)
        }
    }
}
