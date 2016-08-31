//
//  NSObject_Extension.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 31/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

extension NSObject {
    class var className: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}
