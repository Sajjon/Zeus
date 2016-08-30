//
//  Image+CoreDataProperties.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 30/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import CoreData

extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image");
    }

    @NSManaged public var url: String?
    @NSManaged public var heightRaw: Int16
    @NSManaged public var widthRaw: Int16
    @NSManaged public var artist: Artist?
    @NSManaged public var album: Album?

}
