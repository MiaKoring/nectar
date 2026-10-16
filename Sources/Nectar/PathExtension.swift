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
    public let _endpoints: [Endpoint] = []
    public var subgroups: [any EndpointGroup]

    public init(_ partialPath: String, @EndpointBuilder endpoints: () -> [EndpointGroup]) {
        self.partialName = partialPath
        self.subgroups = endpoints()
    }
}
