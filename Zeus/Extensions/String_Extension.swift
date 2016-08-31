//
//  String_Extension.swift
//  Zeus
//
//  Created by Cyon Alexander (Ext. Netlight) on 31/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

extension String {
    func contains(_ find: String) -> Bool {
        return self.range(of: find) != nil
    }

    var length: Int {
        return characters.count
    }
}
