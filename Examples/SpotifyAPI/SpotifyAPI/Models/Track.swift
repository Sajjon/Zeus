//
//  Track+CoreDataClass.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 30/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData


class Track: NSManagedObject {}

extension Track {

    var discNumber: Int {
        return Int(discNumberRaw)
    }

    var durationMs: Int {
        return Int(durationMsRaw)
    }

    var number: Int {
        return Int(trackNumberRaw)
    }
}
