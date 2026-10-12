// ===----------------------------------------------------------------------===
//
// This source file is part of the Nectar open source project
//
// Copyright (c) 2026 Mia Koring.
//
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===

public struct PathExtension: EndpointGroup {
    public let partialName: String
    public let _endpoints: [Endpoint]

    public init(_ partialPath: String, @EndpointBuilder endpoints: () -> [Endpoint]) {
        self.partialName = partialPath
        self._endpoints = endpoints().map {
            Endpoint(
                partialPath: "/" + $0.partialPath,
                httpMethod: $0.httpMethod,
                handler: $0.handler
            )
        }
    }
}
