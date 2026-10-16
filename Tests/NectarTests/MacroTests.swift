// ===----------------------------------------------------------------------===
//
// This source file is part of the Nectar open source project
//
// Copyright (c) 2026 Mia Koring.
//
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===

import Testing
@testable import Nectar
import MacroTesting
import NectarMacros

@Suite(.macros([
    EndpointsMacro.self,
    GetMacro.self,
    PostMacro.self,
    PatchMacro.self,
    DeleteMacro.self
]))
struct MacroTests {
    @Test func `basic expansion`() async throws {
        assertMacro {
            """
            @Endpoints
            struct BasicEndpoints: EndpointGroup {
                let partialName = "basic"

                var subgroups: [Endpoint] { }

                @GET
                func get() -> String { "" }

                @POST
                func post() -> String { "" }

                @PATCH
                func patch() -> String { "" }

                @DELETE
                func delete() -> String { "" }
            }
            """
        } expansion: {
            """
            struct BasicEndpoints: EndpointGroup {
                let partialName = "basic"

                var subgroups: [Endpoint] { }

                @GET
                func get() -> String { "" }

                @POST
                func post() -> String { "" }

                @PATCH
                func patch() -> String { "" }

                @DELETE
                func delete() -> String { "" }

                var _endpoints: [Endpoint] {
                    [
                        Endpoint(
                            partialPath: "",
                            httpMethod: .get,
                            pathParams: [],
                            handler: { request, context in
                                try await _get(request, context)
                            }
                        ),
                        Endpoint(
                            partialPath: "",
                            httpMethod: .post,
                            pathParams: [],
                            handler: { request, context in
                                try await _post(request, context)
                            }
                        ),
                        Endpoint(
                            partialPath: "",
                            httpMethod: .patch,
                            pathParams: [],
                            handler: { request, context in
                                try await _patch(request, context)
                            }
                        ),
                        Endpoint(
                            partialPath: "",
                            httpMethod: .delete,
                            pathParams: [],
                            handler: { request, context in
                                try await _delete(request, context)
                            }
                        )
                    ]
                }
            }

            extension BasicEndpoints {
                func _get(
                    _ request: Request,
                    _ context: any RequestContext
                ) async throws -> Response {

                    return get(

                    ).response(from: request, context: context)
                }
                func _post(
                    _ request: Request,
                    _ context: any RequestContext
                ) async throws -> Response {

                    return post(

                    ).response(from: request, context: context)
                }
                func _patch(
                    _ request: Request,
                    _ context: any RequestContext
                ) async throws -> Response {

                    return patch(

                    ).response(from: request, context: context)
                }
                func _delete(
                    _ request: Request,
                    _ context: any RequestContext
                ) async throws -> Response {

                    return delete(

                    ).response(from: request, context: context)
                }
            }
            """
        }
    }

    @Test func `respects async throws`() async throws {
        assertMacro {
            """
            @Endpoints
            struct BasicEndpoints: EndpointGroup {
                let partialName = "basic"

                var subgroups: [Endpoint] { }

                @GET
                func get() -> String { "" }

                @POST
                func post() async -> String { "" }

                @PATCH
                func patch() throws -> String { "" }

                @DELETE
                func delete() async throws -> String { "" }
            }
            """
        } expansion: {
            """
            struct BasicEndpoints: EndpointGroup {
                let partialName = "basic"

                var subgroups: [Endpoint] { }

                @GET
                func get() -> String { "" }

                @POST
                func post() async -> String { "" }

                @PATCH
                func patch() throws -> String { "" }

                @DELETE
                func delete() async throws -> String { "" }

                var _endpoints: [Endpoint] {
                    [
                        Endpoint(
                            partialPath: "",
                            httpMethod: .get,
                            pathParams: [],
                            handler: { request, context in
                                try await _get(request, context)
                            }
                        ),
                        Endpoint(
                            partialPath: "",
                            httpMethod: .post,
                            pathParams: [],
                            handler: { request, context in
                                try await _post(request, context)
                            }
                        ),
                        Endpoint(
                            partialPath: "",
                            httpMethod: .patch,
                            pathParams: [],
                            handler: { request, context in
                                try await _patch(request, context)
                            }
                        ),
                        Endpoint(
                            partialPath: "",
                            httpMethod: .delete,
                            pathParams: [],
                            handler: { request, context in
                                try await _delete(request, context)
                            }
                        )
                    ]
                }
            }

            extension BasicEndpoints {
                func _get(
                    _ request: Request,
                    _ context: any RequestContext
                ) async throws -> Response {

                    return get(

                    ).response(from: request, context: context)
                }
                func _post(
                    _ request: Request,
                    _ context: any RequestContext
                ) async throws -> Response {

                    return await post(

                    ).response(from: request, context: context)
                }
                func _patch(
                    _ request: Request,
                    _ context: any RequestContext
                ) async throws -> Response {

                    return try patch(

                    ).response(from: request, context: context)
                }
                func _delete(
                    _ request: Request,
                    _ context: any RequestContext
                ) async throws -> Response {

                    return try await delete(

                    ).response(from: request, context: context)
                }
            }
            """
        }
    }

    @Test func `parses function parameters correctly`() async throws {
        assertMacro {
            """
            @Endpoints
            struct BasicEndpoints: EndpointGroup {
                let partialName = "basic"

                var subgroups: [Endpoint] { }

                @GET
                func get(number: Int) -> String { "" }

                @POST
                func post(number: Int?) -> String { "" }

                @PATCH
                func patch(number: Optional<Int>) -> String { "" }

                @DELETE
                func delete(body: String) -> String { "" }

                @DELETE
                func deleteReq(req: Request) -> String { "" }

                @DELETE
                func deleteContext(context: any RequestContext) -> String { "" }

                @DELETE
                func deleteEverything(
                    number: Int,
                    id: UUID?,
                    issue: Optional<UUID>,
                    body: String,
                    req: Request,
                    context: any RequestContext
                ) -> String { "" }
            }
            """
        } expansion: {
            """
            struct BasicEndpoints: EndpointGroup {
                let partialName = "basic"

                var subgroups: [Endpoint] { }

                @GET
                func get(number: Int) -> String { "" }

                @POST
                func post(number: Int?) -> String { "" }

                @PATCH
                func patch(number: Optional<Int>) -> String { "" }

                @DELETE
                func delete(body: String) -> String { "" }

                @DELETE
                func deleteReq(req: Request) -> String { "" }

                @DELETE
                func deleteContext(context: any RequestContext) -> String { "" }

                @DELETE
                func deleteEverything(
                    number: Int,
                    id: UUID?,
                    issue: Optional<UUID>,
                    body: String,
                    req: Request,
                    context: any RequestContext
                ) -> String { "" }

                var _endpoints: [Endpoint] {
                    [
                        Endpoint(
                            partialPath: ":number",
                            httpMethod: .get,
                            pathParams: ["number"],
                            handler: { request, context in
                                try await _get(request, context)
                            }
                        ),
                        Endpoint(
                            partialPath: "",
                            httpMethod: .post,
                            pathParams: [],
                            handler: { request, context in
                                try await _post(request, context)
                            }
                        ),
                        Endpoint(
                            partialPath: "",
                            httpMethod: .patch,
                            pathParams: [],
                            handler: { request, context in
                                try await _patch(request, context)
                            }
                        ),
                        Endpoint(
                            partialPath: "",
                            httpMethod: .delete,
                            pathParams: [],
                            handler: { request, context in
                                try await _delete(request, context)
                            }
                        ),
                        Endpoint(
                            partialPath: "",
                            httpMethod: .delete,
                            pathParams: [],
                            handler: { request, context in
                                try await _deleteReq(request, context)
                            }
                        ),
                        Endpoint(
                            partialPath: "",
                            httpMethod: .delete,
                            pathParams: [],
                            handler: { request, context in
                                try await _deleteContext(request, context)
                            }
                        ),
                        Endpoint(
                            partialPath: ":number",
                            httpMethod: .delete,
                            pathParams: ["number"],
                            handler: { request, context in
                                try await _deleteEverything(request, context)
                            }
                        )
                    ]
                }
            }

            extension BasicEndpoints {
                func _get(
                    _ request: Request,
                    _ context: any RequestContext
                ) async throws -> Response {
                    let _number = try context.parameters.require("number")
                    guard let number = Int(fromString: _number) else {
                        throw ParameterConversionError.failedConversionFromString(name: "number")
                    }

                    return get(
                        number: number
                    ).response(from: request, context: context)
                }
                func _post(
                    _ request: Request,
                    _ context: any RequestContext
                ) async throws -> Response {
                    let _number = request.uri.queryParameters["number"]
                    let number = Int?(fromString: _number)

                    return post(
                        number: number
                    ).response(from: request, context: context)
                }
                func _patch(
                    _ request: Request,
                    _ context: any RequestContext
                ) async throws -> Response {
                    let _number = request.uri.queryParameters["number"]
                    let number = Optional<Int>(fromString: _number)

                    return patch(
                        number: number
                    ).response(from: request, context: context)
                }
                func _delete(
                    _ request: Request,
                    _ context: any RequestContext
                ) async throws -> Response {
                    let body = try await request.decode(
                        as: String.self,
                        context: context
                    )

                    return delete(
                        body: body
                    ).response(from: request, context: context)
                }
                func _deleteReq(
                    _ request: Request,
                    _ context: any RequestContext
                ) async throws -> Response {

                    return deleteReq(
                        req: request
                    ).response(from: request, context: context)
                }
                func _deleteContext(
                    _ request: Request,
                    _ context: any RequestContext
                ) async throws -> Response {

                    return deleteContext(
                        context: context
                    ).response(from: request, context: context)
                }
                func _deleteEverything(
                    _ request: Request,
                    _ context: any RequestContext
                ) async throws -> Response {
                    let body = try await request.decode(
                        as: String.self,
                        context: context
                    )
                    let _id = request.uri.queryParameters["id"]
                    let id = UUID?(fromString: _id)
                    let _issue = request.uri.queryParameters["issue"]
                    let issue = Optional<UUID>(fromString: _issue)
                    let _number = try context.parameters.require("number")
                    guard let number = Int(fromString: _number) else {
                        throw ParameterConversionError.failedConversionFromString(name: "number")
                    }

                    return deleteEverything(
                        number: number,
                        id: id,
                        issue: issue,
                        body: body,
                        req: request,
                        context: context
                    ).response(from: request, context: context)
                }
            }
            """
        }
    }

    @Test func `respects pattern`() async throws {
        assertMacro {
            """
            @Endpoints
            struct BasicEndpoints: EndpointGroup {
                let partialName = "basic"

                var subgroups: [Endpoint] { }

                @GET(pattern: ":number/activity")
                func get(number: Int) -> String { "" }

                @POST(pattern: "integer1")
                func post(number: Int?) -> String { "" }

                @PATCH(pattern: "integer2")
                func patch(number: Optional<Int>) -> String { "" }

                @DELETE(pattern: "body")
                func delete(body: String) -> String { "" }

                @DELETE(pattern: "request")
                func deleteReq(req: Request) -> String { "" }

                @DELETE(pattern: "context")
                func deleteContext(context: any RequestContext) -> String { "" }

                @DELETE(pattern: ":number/activity")
                func deleteEverything(
                    number: Int,
                    id: UUID?,
                    issue: Optional<UUID>,
                    body: String,
                    req: Request,
                    context: any RequestContext
                ) -> String { "" }
            }
            """
        } expansion: {
            """
            struct BasicEndpoints: EndpointGroup {
                let partialName = "basic"

                var subgroups: [Endpoint] { }

                @GET(pattern: ":number/activity")
                func get(number: Int) -> String { "" }

                @POST(pattern: "integer1")
                func post(number: Int?) -> String { "" }

                @PATCH(pattern: "integer2")
                func patch(number: Optional<Int>) -> String { "" }

                @DELETE(pattern: "body")
                func delete(body: String) -> String { "" }

                @DELETE(pattern: "request")
                func deleteReq(req: Request) -> String { "" }

                @DELETE(pattern: "context")
                func deleteContext(context: any RequestContext) -> String { "" }

                @DELETE(pattern: ":number/activity")
                func deleteEverything(
                    number: Int,
                    id: UUID?,
                    issue: Optional<UUID>,
                    body: String,
                    req: Request,
                    context: any RequestContext
                ) -> String { "" }

                var _endpoints: [Endpoint] {
                    [
                        Endpoint(
                            partialPath: ":number/activity",
                            httpMethod: .get,
                            pathParams: ["number"],
                            handler: { request, context in
                                try await _get(request, context)
                            }
                        ),
                        Endpoint(
                            partialPath: "integer1",
                            httpMethod: .post,
                            pathParams: [],
                            handler: { request, context in
                                try await _post(request, context)
                            }
                        ),
                        Endpoint(
                            partialPath: "integer2",
                            httpMethod: .patch,
                            pathParams: [],
                            handler: { request, context in
                                try await _patch(request, context)
                            }
                        ),
                        Endpoint(
                            partialPath: "body",
                            httpMethod: .delete,
                            pathParams: [],
                            handler: { request, context in
                                try await _delete(request, context)
                            }
                        ),
                        Endpoint(
                            partialPath: "request",
                            httpMethod: .delete,
                            pathParams: [],
                            handler: { request, context in
                                try await _deleteReq(request, context)
                            }
                        ),
                        Endpoint(
                            partialPath: "context",
                            httpMethod: .delete,
                            pathParams: [],
                            handler: { request, context in
                                try await _deleteContext(request, context)
                            }
                        ),
                        Endpoint(
                            partialPath: ":number/activity",
                            httpMethod: .delete,
                            pathParams: ["number"],
                            handler: { request, context in
                                try await _deleteEverything(request, context)
                            }
                        )
                    ]
                }
            }

            extension BasicEndpoints {
                func _get(
                    _ request: Request,
                    _ context: any RequestContext
                ) async throws -> Response {
                    let _number = try context.parameters.require("number")
                    guard let number = Int(fromString: _number) else {
                        throw ParameterConversionError.failedConversionFromString(name: "number")
                    }

                    return get(
                        number: number
                    ).response(from: request, context: context)
                }
                func _post(
                    _ request: Request,
                    _ context: any RequestContext
                ) async throws -> Response {
                    let _number = request.uri.queryParameters["number"]
                    let number = Int?(fromString: _number)

                    return post(
                        number: number
                    ).response(from: request, context: context)
                }
                func _patch(
                    _ request: Request,
                    _ context: any RequestContext
                ) async throws -> Response {
                    let _number = request.uri.queryParameters["number"]
                    let number = Optional<Int>(fromString: _number)

                    return patch(
                        number: number
                    ).response(from: request, context: context)
                }
                func _delete(
                    _ request: Request,
                    _ context: any RequestContext
                ) async throws -> Response {
                    let body = try await request.decode(
                        as: String.self,
                        context: context
                    )

                    return delete(
                        body: body
                    ).response(from: request, context: context)
                }
                func _deleteReq(
                    _ request: Request,
                    _ context: any RequestContext
                ) async throws -> Response {

                    return deleteReq(
                        req: request
                    ).response(from: request, context: context)
                }
                func _deleteContext(
                    _ request: Request,
                    _ context: any RequestContext
                ) async throws -> Response {

                    return deleteContext(
                        context: context
                    ).response(from: request, context: context)
                }
                func _deleteEverything(
                    _ request: Request,
                    _ context: any RequestContext
                ) async throws -> Response {
                    let body = try await request.decode(
                        as: String.self,
                        context: context
                    )
                    let _id = request.uri.queryParameters["id"]
                    let id = UUID?(fromString: _id)
                    let _issue = request.uri.queryParameters["issue"]
                    let issue = Optional<UUID>(fromString: _issue)
                    let _number = try context.parameters.require("number")
                    guard let number = Int(fromString: _number) else {
                        throw ParameterConversionError.failedConversionFromString(name: "number")
                    }

                    return deleteEverything(
                        number: number,
                        id: id,
                        issue: issue,
                        body: body,
                        req: request,
                        context: context
                    ).response(from: request, context: context)
                }
            }
            """
        }
    }

    @Test func `warns for unused parameters`() async throws {
        assertMacro {
            """
            @Endpoints
            struct BasicEndpoints: EndpointGroup {
                let partialName = "basic"

                var subgroups: [Endpoint] { }

                @GET(pattern: ":number/activity")
                func get() -> String { "" }
            }
            """
        } diagnostics: {
            """
            @Endpoints
            struct BasicEndpoints: EndpointGroup {
                let partialName = "basic"

                var subgroups: [Endpoint] { }

                @GET(pattern: ":number/activity")
                ┬────────────────────────────────
                ╰─ ⚠️ Unused path parameter: 'number'. Consider using a wildcard instead.
                func get() -> String { "" }
            }
            """
        } expansion: {
            """
            struct BasicEndpoints: EndpointGroup {
                let partialName = "basic"

                var subgroups: [Endpoint] { }

                @GET(pattern: ":number/activity")
                func get() -> String { "" }

                var _endpoints: [Endpoint] {
                    [
                        Endpoint(
                            partialPath: ":number/activity",
                            httpMethod: .get,
                            pathParams: [],
                            handler: { request, context in
                                try await _get(request, context)
                            }
                        )
                    ]
                }
            }

            extension BasicEndpoints {
                func _get(
                    _ request: Request,
                    _ context: any RequestContext
                ) async throws -> Response {

                    return get(

                    ).response(from: request, context: context)
                }
            }
            """
        }
    }

    @Test func `fails for illegal parameter`() async throws {
        assertMacro {
            """
            @Endpoints
            struct BasicEndpoints: EndpointGroup {
                let partialName = "basic"

                var subgroups: [Endpoint] { }

                @GET(pattern: ":req/:con/:body/:test")
                func get(req: Request, con: any RequestContext) -> String { "" }
            }
            """
        } diagnostics: {
            """
            @Endpoints
            struct BasicEndpoints: EndpointGroup {
                let partialName = "basic"

                var subgroups: [Endpoint] { }

                @GET(pattern: ":req/:con/:body/:test")
                ┬─────────────────────────────────────
                ├─ 🛑 Use of forbidden path parameter: 'req' is not allowed in this context. It is already reserved.
                ├─ 🛑 Use of forbidden path parameter: 'con' is not allowed in this context. It is already reserved.
                ├─ 🛑 Use of forbidden path parameter: 'body' is not allowed in this context. It is already reserved.
                ╰─ ⚠️ Unused path parameter: 'test'. Consider using a wildcard instead.
                func get(req: Request, con: any RequestContext) -> String { "" }
            }
            """
        }
    }

    @Test func `reports path parameter declared as url parameter`() async throws {
        assertMacro {
            """
            @Endpoints
            struct BasicEndpoints: EndpointGroup {
                let partialName = "basic"

                var subgroups: [Endpoint] { }

                @GET(pattern: ":number/activity")
                func get(number: Int?) -> String { "" }
            }
            """
        } diagnostics: {
            """
            @Endpoints
            struct BasicEndpoints: EndpointGroup {
                let partialName = "basic"

                var subgroups: [Endpoint] { }

                @GET(pattern: ":number/activity")
                ┬────────────────────────────────
                ╰─ 🛑 Path parameter 'number' declared as optional on the function. Path parameters cannot be optional. Make it non-optional or use a wildcard instead to use it as query parameter.
                func get(number: Int?) -> String { "" }
            }
            """
        }
    }
}
