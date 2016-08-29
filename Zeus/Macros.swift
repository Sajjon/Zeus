//
//  Macros.swift
//  Zeus
//
//  Created by Cyon Alexander on 22/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

let mustOverride = "must override"

public var documentsFolder: URL? {
    let fileManager = FileManager.default
    let path = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last
    return path
}

public var documentsFolderPath: String? {
    return documentsFolder?.absoluteString
}
