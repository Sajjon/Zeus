//
//  DateFormatter_Extension.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 05/09/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

extension DateFormatter {
    convenience init(dateStyle: DateFormatter.Style) {
        self.init()
        self.dateStyle = dateStyle
    }
}
