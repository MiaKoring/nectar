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
