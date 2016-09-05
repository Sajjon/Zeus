//
//  Date_Extension.swift
//  SpotifyAPI
//
//  Created by Cyon Alexander (Ext. Netlight) on 05/09/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

extension NSDate {
    struct Formatter {
        static let shortDate = DateFormatter(dateStyle: .short)
    }

    convenience init?(short dateString: String) {
        self.init()
        guard let fromString = Formatter.shortDate.date(from: dateString) else { return nil }
        self.addingTimeInterval(fromString.timeIntervalSince1970)
    }
}
