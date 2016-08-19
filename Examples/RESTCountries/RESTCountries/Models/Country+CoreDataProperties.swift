//
//  Country+CoreDataProperties.swift
//  
//
//  Created by Cyon Alexander (Ext. Netlight) on 19/08/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Country {

    @NSManaged var capital: String
    @NSManaged var name: String

}
