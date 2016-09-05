//
//  Album+CoreDataClass.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 30/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData


class Album: NSManagedObject {}

extension Album {

    var artists: [Artist]? {
        return artistsSet?.allObjects as? [Artist]
    }

    var images: [Image]? {
        return imagesSet?.allObjects as? [Image]
    }

    var tracks: [Track]? {
        return tracksOrderedSet?.array as? [Track]
    }

    var releaseDateString: String? {
        guard let date = releaseDate as? Date else { return nil }
        let string = date.shortDate
        return string
    }

    var popularity: Int? {
        return popularityRaw as? Int
    }

}
