//
//  Zeus.swift
//  Zeus
//
//  Created by Cyon Alexander (Ext. Netlight) on 23/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation
import SwiftyBeaver

internal let log = SwiftyBeaver.self

public typealias QueryParameters = Dictionary<String, String>
public typealias JSONMapping = Dictionary<String, String>
public typealias Done = (Result) -> Void

public typealias Attribute = NSObject
internal typealias JSON = Dictionary<String, NSObject>
internal typealias MappedJSON = JSON

public var logLevel: SwiftyBeaver.Level {
set {
    DataStore.sharedInstance.logLevel = newValue
}
get {
    return DataStore.sharedInstance.logLevel
}
}

//MARK: Internal Methods
internal func consoleLogging(withLogLevel logLevel: SwiftyBeaver.Level) -> ConsoleDestination {
    let console = ConsoleDestination()
    console.minLevel = logLevel
    return console
}

internal func onlineLogging(withLogLevel logLevel: SwiftyBeaver.Level = SwiftyBeaver.Level.Verbose) -> SBPlatformDestination {
    let platform = SBPlatformDestination(appID: "JXQQg9", appSecret: "tWqdzRHpKR5WHwbKmrgirDm00aifLb9i", encryptionKey: "cfs8naga3R4ggyyjnpbtkynp4zh86n1c")
    platform.minLevel = logLevel
    return platform
}