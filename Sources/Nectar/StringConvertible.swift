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

public protocol StringConvertible {
    init?(fromString string: String)
}

extension UUID: StringConvertible {
    public init?(fromString string: String) {
        self.init(uuidString: string)
    }
}

extension Int: StringConvertible {
    public init?(fromString string: String) {
        self.init(string)
    }
}

extension Int8: StringConvertible {
    public init?(fromString string: String) {
        self.init(string)
    }
}

extension Int16: StringConvertible {
    public init?(fromString string: String) {
        self.init(string)
    }
}

extension Int32: StringConvertible {
    public init?(fromString string: String) {
        self.init(string)
    }
}

extension Int64: StringConvertible {
    public init?(fromString string: String) {
        self.init(string)
    }
}

extension UInt8: StringConvertible {
    public init?(fromString string: String) {
        self.init(string)
    }
}

extension UInt16: StringConvertible {
    public init?(fromString string: String) {
        self.init(string)
    }
}

extension UInt32: StringConvertible {
    public init?(fromString string: String) {
        self.init(string)
    }
}

extension UInt64: StringConvertible {
    public init?(fromString string: String) {
        self.init(string)
    }
}

extension Bool: StringConvertible {
    public init?(fromString string: String) {
        self.init(string)
    }
}

extension Optional: StringConvertible where Wrapped: StringConvertible {
    public init(fromString string: String) {
        self = Wrapped(fromString: string)
    }

    public init(fromString string: String?) {
        guard let string else {
            self = nil
            return
        }
        self = Wrapped(fromString: string)
    }

    public init(fromString substr: Substring?) {
        guard let substr else {
            self = nil
            return
        }
        self.init(fromString: String(substr))
    }
}
