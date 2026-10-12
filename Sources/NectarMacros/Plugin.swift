// ===----------------------------------------------------------------------===
//
// This source file is part of the Nectar open source project
//
// Copyright (c) 2026 Mia Koring.
//
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct NectarMacrosPlugin: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        EndpointsMacro.self,
        GetMacro.self,
        PostMacro.self,
        PatchMacro.self,
        DeleteMacro.self
    ]
}
