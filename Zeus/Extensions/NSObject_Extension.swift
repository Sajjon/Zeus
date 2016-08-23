//
//  NSObject_Extension.swift
//  Zeus
//
//  Created by Cyon Alexander on 22/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation


extension NSObject {
    class var className: String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
}