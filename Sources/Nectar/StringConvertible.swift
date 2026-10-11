import Foundation

public protocol StringConvertible {
    var asString: String { get }
    
    init?(from: String)
}

extension UUID: StringConvertible {
    public var asString: String {
        uuidString
    }
    
    public init?(from: String) {
        self.init(uuidString: from)
    }
}
