// ===----------------------------------------------------------------------===
//
// This source file is part of the Nectar open source project
//
// Copyright (c) 2026 Mia Koring.
//
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===

@attached(body)
public macro GET(pattern: String? = nil) = #externalMacro(module: "NectarMacros", type: "GetMacro")
@attached(body)
public macro PATCH(pattern: String? = nil) = #externalMacro(
    module: "NectarMacros",
    type: "PatchMacro"
)
@attached(body)
public macro POST(pattern: String? = nil) = #externalMacro(
    module: "NectarMacros",
    type: "PostMacro"
)
@attached(body)
public macro DELETE(pattern: String? = nil) = #externalMacro(
    module: "NectarMacros",
    type: "DeleteMacro"
)

@attached(member, names: named(_endpoints))
@attached(extension, names: arbitrary)
public macro Endpoints() = #externalMacro(module: "NectarMacros", type: "EndpointsMacro")
