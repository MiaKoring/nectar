// ===----------------------------------------------------------------------===
//
// This source file is part of the Nectar open source project
//
// Copyright (c) 2026 Mia Koring.
//
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===

@resultBuilder
public struct EndpointBuilder {
    public static func buildBlock(_ components: EndpointDeclaration...) -> [Endpoint] {
        return components.reduce(into: [Endpoint]()) { $0 += $1.endpoints }
    }
}
