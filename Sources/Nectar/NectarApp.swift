public protocol NectarApp {
    @EndpointBuilder
    var endpoints: [Endpoint] { get }
}
