//
//  Macros.swift
//  Zeus
//
//  Created by Cyon Alexander on 22/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation


public var documentsFolder: NSURL? {
    let fileManager = NSFileManager.defaultManager()
    let path = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last
    return path
}

public var documentsFolderPath: String? {
    return documentsFolder?.absoluteString
}

func err(error: Error) -> NSError {
    let userInfo = [NSLocalizedFailureReasonErrorKey: error.errorMessage]
    let error = NSError(domain: "Zeus", code: error.rawValue, userInfo: userInfo)
    return error
}

