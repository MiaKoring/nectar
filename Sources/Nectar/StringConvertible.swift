import Foundation

public protocol StringConvertible {
    init?(fromString string: String)
}

extension UUID: StringConvertible {
    public init?(fromString string: String) {
        self.init(uuidString: string)
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
