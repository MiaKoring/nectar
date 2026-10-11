@resultBuilder
public struct EndpointBuilder {
    public static func buildBlock(_ components: EndpointDeclaration...) -> [Endpoint] {
        return components.reduce(into: [Endpoint]()) { $0 += $1.endpoints }
    }
}
