public protocol EndpointDeclaration {
    var partialName: String { get }
    
    var endpoints: [Endpoint] { get }
}
