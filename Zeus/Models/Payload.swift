//
//  Payload.swift
//  Zeus
//
//  Created by Cyon Alexander (Ext. Netlight) on 06/09/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

protocol PayloadProtocol {
    var json: JSON { get }
    var path: APIPathProtocol { get }
    var options: Options { get }
}

struct Payload: PayloadProtocol {
    let json: JSON
    let path: APIPathProtocol
    let options: Options
}
