//
//  Image+CoreDataClass.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 30/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData

class Image: NSManagedObject {}

extension Image {
    var width: Int {
        return Int(widthRaw)
    }

    var height: Int {
        return Int(heightRaw)
    }
}
