//
//  Result.swift
//  Zeus
//
//  Created by Cyon Alexander on 22/08/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

public struct Result {
    public let data: Any?
    public let error: NSError?

    init(_ error: Zeus.Error) {
        self.init(error: err(error))
    }

    init(data: Any? = nil, error: NSError? = nil) {
        let bothNil = data == nil && error == nil
        let noneNil = data != nil && error != nil
        guard !bothNil && !noneNil else { fatalError("Data and error cant be nil or not nil at the same time") }
        self.data = data
        self.error = error
    }
}