// ===----------------------------------------------------------------------===
//
// This source file is part of the Nectar open source project
//
// Copyright (c) 2026 Mia Koring.
//
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===

import Foundation

public enum EndpointAdditionError: Error {
    case missingPathParameter(String, String)
}

extension EndpointAdditionError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            case .missingPathParameter(let string, let uri):
                "The required path parameter '\(string)' is not part of the URI '\(uri)'"
        }
    }
}
