// ===----------------------------------------------------------------------===
//
// This source file is part of the Nectar open source project
//
// Copyright (c) 2026 Mia Koring.
//
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===

import Hummingbird
import HummingbirdTesting
import Testing
import Nectar
import Foundation
import Configuration

private let reader = ConfigReader(providers: [
    InMemoryProvider(values: [
        "host": "127.0.0.1",
        "port": "0",
        "log.level": "trace"
    ])
])

@Suite struct RouteGenerationTests {
    @Test func `all routes registered`() {
        let router = Router()
        router.registerNectarApp(App())

        let routes = router.routes.map(\.description).sorted()

        let expectedRoutes = [
            "POST /users",
            "GET /users/{id}",
            "GET /users/{id}/activity",
            "GET /users/{id}/comments",
            "GET /products",
            "PATCH /products/{id}/price"
        ].sorted()

        #expect(routes == expectedRoutes)
    }

    @Test func testAllRoutes() async throws {
        let app = buildApplication()

        try await app.test(.router) { client in
            let uuid = UUID()
            let response = try await client.execute(
                uri: "/users/\(uuid.uuidString)?includeDetails=true",
                method: .get
            )
            let body = String(buffer: response.body)

            #expect(response.status == .ok)
            #expect(body == "GET user \(uuid.uuidString), includeDetails: true")
        }

        try await app.test(.router) { client in
            let userCreation = UserCreationDTO(name: "Herbert", age: 99999)
            let buffer = try JSONEncoder().encodeAsByteBuffer(
                userCreation,
                allocator: ByteBufferAllocator()
            )

            let response = try await client.execute(
                uri: "/users",
                method: .post,
                body: buffer
            )

            let body = String(buffer: response.body)

            #expect(response.status == .ok)
            #expect(body == "create user name: \(userCreation.name), age: \(userCreation.age)")
        }

        try await app.test(.router) { client in
            let uuid = UUID()
            let response = try await client.execute(
                uri: "/users/\(uuid.uuidString)/activity",
                method: .get
            )
            let body = String(buffer: response.body)

            #expect(response.status == .ok)
            #expect(body == "GET activity for user \(uuid.uuidString)")
        }

        try await app.test(.router) { client in
            let uuid = UUID()
            let response = try await client.execute(
                uri: "/users/\(uuid.uuidString)/comments",
                method: .get
            )
            let body = String(buffer: response.body)

            #expect(response.status == .ok)
            #expect(body == "GET comments \(uuid.uuidString)")
        }

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/products",
                method: .get
            )
            let body = String(buffer: response.body)

            #expect(response.status == .ok)
            #expect(body == "GET products /products")
        }

        try await app.test(.router) { client in
            let uuid = UUID()

            let updatePrice = PriceUpdateDTO(newPrice: 2)
            let buffer = try JSONEncoder().encodeAsByteBuffer(
                updatePrice,
                allocator: ByteBufferAllocator()
            )

            let response = try await client.execute(
                uri: "/products/\(uuid.uuidString)/price",
                method: .patch,
                body: buffer
            )

            let body = String(buffer: response.body)

            #expect(response.status == .ok)
            #expect(body == "PATCH price for product \(uuid.uuidString): \(updatePrice.newPrice)")
        }
    }

    func buildApplication() -> some ApplicationProtocol {
        let router = Router()
        router.registerNectarApp(App())
        let app = Application(
            router: router,
            configuration: ApplicationConfiguration(reader: reader.scoped(to: "http"))
        )

        return app
    }
}

fileprivate struct App: NectarApp {
    var endpoints: [Endpoint] {
        UserEndpointGroup()
        ProductEndpointGroup()
    }
}

@Endpoints
fileprivate struct UserEndpointGroup: EndpointGroup {
    let partialName = "users"

    var subgroups: [Endpoint] {
        // Tests nested path composition: /users/:id/comments
        PathExtension(":id") {
            UserCommentEndpointGroup()
        }
    }

    // Tests: path param + optional query param
    @GET
    func getUser(id: UUID, includeDetails: Bool?) -> String {
        "GET user \(id.uuidString), includeDetails: \(includeDetails ?? false)"
    }

    // Tests: explicit pattern override
    @GET(pattern: ":id/activity")
    func getUserActivity(id: UUID) -> String {
        "GET activity for user \(id.uuidString)"
    }

    // Tests: body decoding + async/throws
    @POST
    func createUser(body: UserCreationDTO) async throws -> String {
        "create user name: \(body.name), age: \(body.age)"
    }
}

@Endpoints
fileprivate struct UserCommentEndpointGroup: EndpointGroup {
    let partialName = "comments"

    // Tests: inherits parent path param + empty pattern override
    @GET(pattern: "")
    func getComments(id: UUID) -> String { "GET comments \(id.uuidString)" }
}

@Endpoints
fileprivate struct ProductEndpointGroup: EndpointGroup {
    let partialName = "products"

    // Tests: raw Request access
    @GET
    func getProducts(request: Request) -> String {
        "GET products \(request.uri.description)"
    }

    // Tests: custom path pattern + body
    @PATCH(pattern: ":id/price")
    func updatePrice(id: UUID, body: PriceUpdateDTO) -> String {
        "PATCH price for product \(id.uuidString): \(body.newPrice)"
    }
}

fileprivate struct PriceUpdateDTO: Codable {
    var newPrice: Int
}
fileprivate struct UserCreationDTO: Codable {
    var name: String
    var age: Int
}
