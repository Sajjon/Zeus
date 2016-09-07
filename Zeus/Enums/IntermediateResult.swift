//
//  IntermediateResult.swift
//  Zeus
//
//  Created by Cyon Alexander (Ext. Netlight) on 06/09/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//

import Foundation

internal enum IntermediateResult {
    case success(Any)
    case failure(ZeusError)

    internal init(_ error: ZeusError) {
        self = .failure(error)
    }

    internal init(_ data: Any) {
        self = .success(data)
    }

    /// Returns `true` if the result is a success, `false` otherwise.
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    /// Returns `true` if the result is a failure, `false` otherwise.
    public var isFailure: Bool {
        return !isSuccess
    }

    /// Returns the associated value if the result is a success, `nil` otherwise.
    public var value: Any? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }

    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    public var error: NSError? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error.error
        }
    }

}
