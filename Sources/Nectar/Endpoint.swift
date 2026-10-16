// ===----------------------------------------------------------------------===
//
// This source file is part of the Nectar open source project
//
// Copyright (c) 2026 Mia Koring.
//
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===

@_exported import Hummingbird

public struct Endpoint {
    let partialPath: String
    let httpMethod: HTTPMethod
    let pathParams: [String]

    let handler: @Sendable (Request, any RequestContext) async throws -> Response

    public init(
        partialPath: String,
        httpMethod: HTTPMethod,
        pathParams: [String],
        handler: @Sendable @escaping (Request, any RequestContext) async throws -> Response
    ) {
        self.partialPath = partialPath
        self.httpMethod = httpMethod
        self.handler = handler
        self.pathParams = pathParams
    }
}
