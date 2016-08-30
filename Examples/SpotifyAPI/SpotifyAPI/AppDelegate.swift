//
//  AppDelegate.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 30/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import UIKit
import Zeus
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder {

    static var sharedInstance: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    static var modelManager: ModelManagerProtocol {
        return sharedInstance.zeusConfig.modelManager
    }
    var zeusConfig: ZeusConfigurator!
    var window: UIWindow?

}

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: Any]?) -> Bool {
        zeusConfig = ZeusConfigurator()
        return true
    }
}
