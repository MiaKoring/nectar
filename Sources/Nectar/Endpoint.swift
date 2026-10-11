@_exported import Hummingbird

public struct Endpoint {
    let partialPath: String
    let httpMethod: HTTPMethod
    
    let handler: @Sendable (Request, any RequestContext) async throws -> String
    
    public init(partialPath: String, httpMethod: HTTPMethod, handler: @Sendable @escaping (Request, any RequestContext) async throws -> String) {
        self.partialPath = partialPath
        self.httpMethod = httpMethod
        self.handler = handler
    }
}
