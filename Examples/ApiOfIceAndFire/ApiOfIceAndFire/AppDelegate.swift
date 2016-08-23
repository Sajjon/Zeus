//
//  AppDelegate.swift
//  ApiOfIceAndFire
//
//  Created by Alexander Georgii-Hemming Cyon on 20/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import UIKit
import Zeus
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder {

    static var sharedInstance: AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    static var modelManager: ModelManagerProtocol {
        return sharedInstance.zeusConfig.modelManager
    }
    var zeusConfig: ZeusConfigurator!
    var window: UIWindow?

}

extension AppDelegate: UIApplicationDelegate {
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        zeusConfig = ZeusConfigurator()
        return true
    }
}