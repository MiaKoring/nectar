// ===----------------------------------------------------------------------===
//
// This source file is part of the Nectar open source project
//
// Copyright (c) 2026 Mia Koring.
//
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===

public protocol EndpointGroup: EndpointDeclaration {
    var _endpoints: [Endpoint] { get }
    @EndpointBuilder
    var subgroups: [Endpoint] { get }
}

extension EndpointGroup {
    public var endpoints: [Endpoint] {
        (_endpoints + subgroups).map {
            Endpoint(
                partialPath: partialName + "/" + $0.partialPath,
                httpMethod: $0.httpMethod,
                handler: $0.handler
            )
        }
    }

    public var subgroups: [Endpoint] {
        []
    }
}
