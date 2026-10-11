import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion
import SwiftDiagnostics
import SwiftBasicFormat

public struct EndpointsMacro {}
extension EndpointsMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structNode = StructDeclSyntax(declaration) else {
            context.diagnose(Diagnostic(
                node: node,
                message: Message(
                    message: "@Endpoints can only be applied to structs",
                    id: "endpoints-can-only-be-applied-to-structs",
                    severity: .error
                )
            ))
            
            return []
        }
        
        let endpointExprs: [ExprSyntax] = structNode.endpoints(context: context)
        let arrayElementList = ArrayElementListSyntax(
            endpointExprs.enumerated().map { index, expr in
                ArrayElementSyntax(
                    expression: expr,
                    trailingComma: index == endpointExprs.count - 1 ? nil : .commaToken(trailingTrivia: .newline)
                )
            }
        )
        
        let code: DeclSyntax = #"""
        var _endpoints: [Endpoint] {
            [
                \#(arrayElementList)
            ]
        }
        """#
        
        let formatted = code.formatted()
        
        return [formatted.as(DeclSyntax.self)!]
    }
}

extension EndpointsMacro: PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        []
    }
}
