// ===----------------------------------------------------------------------===
//
// This source file is part of the Nectar open source project
//
// Copyright (c) 2026 Mia Koring.
//
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion
import SwiftDiagnostics
import SwiftBasicFormat

extension StructDeclSyntax {
    func endpoints(context: some MacroExpansionContext) -> [ExprSyntax] {
        let functions = memberBlock.members
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }

        var endpoints = [ExprSyntax]()

        for function in functions {
            guard let method = function.httpMethod else { continue }
            guard
                let returnClause = function.signature.returnClause
            else {
                context.diagnose(Diagnostic(
                    node: function,
                    message: Message(
                        message: "Function needs a return value.",
                        id: "function-needs-return-value",
                        severity: .error
                    )
                ))
                continue
            }
            guard returnClause.type.trimmedDescription != "Void" else {
                context.diagnose(Diagnostic(
                    node: returnClause,
                    message: Message(
                        message: "Function needs a return a non-void value.",
                        id: "function-needs-non-void-return-value",
                        severity: .error
                    )
                ))
                continue
            }

            let arguments = function.arguments

            method.reportIllegalParameters(for: arguments, using: context)
            method.warnUnusedParameters(for: arguments, using: context)
                
            let pathParameters = arguments.filter { (name, type) in
                name != "body" && type.typeAllowsPathParameter
            }
            
            let pathParametersString = pathParameters.map { ":\($0.0)" }

            let partialPath = method.pattern
                ?? pathParametersString.joined(separator: "/")

            let name = function.name.text
            
            let pathParametersArray = pathParameters.map { "\"\($0.0)\"" }.joined(separator: ", ")

            endpoints.append(
                """
                Endpoint(
                    partialPath: \(literal: partialPath),
                    httpMethod: .\(raw: method.method),
                    pathParams: [\(raw: pathParametersArray)],
                    handler: { request, context in
                        try await _\(raw: name)(request, context) 
                    }
                )
                """
            )
        }

        return endpoints
    }

    func helperFunctions(context: some MacroExpansionContext) -> [DeclSyntax] {
        return memberBlock.members
            .compactMap {
                guard let function = $0.decl.as(FunctionDeclSyntax.self) else { return nil }
                return function.correspondingHelper(context: context)
            }
    }
}

extension FunctionDeclSyntax {
    func correspondingHelper(context: some MacroExpansionContext) -> DeclSyntax? {
        guard let _ = httpMethod else { return nil }

        let pathParameters = arguments.filter { (name, type) in
            name != "body" && type.typeAllowsPathParameter
        }

        let body = arguments.first(where: { $0.0 == "body" })

        let queryParams = arguments.filter { (name, type) in
            name != "body" && type.typeAllowsQueryParameter
        }

        let bodyString: String

        if let body {
            bodyString = #"""
                let body = try await request.decode(
                        as: \#(body.1).self,
                        context: context
                    )
                """# + "\n"
        } else { bodyString = ""}

        var queryParamsString = queryParams.map { (name, type) in
            return #"""
                let _\#(name) = request.uri.queryParameters["\#(name)"]
                let \#(name) = \#(type)(fromString: _\#(name))
                """#
        }.joined(separator: "\n")

        if !queryParamsString.isEmpty {
            queryParamsString += "\n"
        }

        var pathParamsString = pathParameters.map { (name, type) in
            return #"""
                let _\#(name) = try context.parameters.require("\#(name)")
                guard let \#(name) = \#(type)(fromString: _\#(name)) else {
                    throw ParameterConversionError.failedConversionFromString(name: "\#(name)")
                }
                """#
        }.joined(separator: "\n")

        if !pathParamsString.isEmpty {
            pathParamsString += "\n"
        }

        let functionParameters = arguments.map { (name, type) in
            if type.isContext {
                "\(name): context"
            } else if type.isRequest {
                "\(name): request"
            } else {
                "\(name): \(name)"
            }
        }.joined(separator: ",\n")

        let awaitClause = signature.effectSpecifiers?.asyncSpecifier != nil ? "await " : ""
        let tryClause = signature.effectSpecifiers?.throwsClause?
            .throwsSpecifier != nil ? "try " : ""

        return #"""
            func _\#(raw: name.text)(
                _ request: Request,
                _ context: any RequestContext
            ) async throws -> Response {
                \#(raw: bodyString)\#(raw: queryParamsString)\#(raw: pathParamsString)
                return \#(raw: tryClause)\#(raw: awaitClause)\#(raw: name.text)(
                    \#(raw: functionParameters)
                ).response(from: request, context: context)
            }
            """#
    }

    private var methods: [String] {
        ["GET", "DELETE", "POST", "PATCH"]
    }

    var httpMethod: HTTPMethod? {
        for method in methods {
            if let result = attributeOrMacro(matching: "\(method)") {
                return HTTPMethod(result)
            }
            if let result = attributeOrMacro(matching: "Nectar.\(method)") {
                return HTTPMethod(result)
            }
        }
        return nil
    }

    func attributeOrMacro(matching name: String) -> AttributeSyntax? {
        let parts = name.split(separator: ".")

        var expectation: [TokenKind] = []

        for (i, identifier) in parts.enumerated() {
            expectation.append(.identifier(String(identifier)))

            if i < parts.count - 1 {
                expectation.append(.period)
            }
        }

        for attribute in attributes {
            switch attribute {
                case .attribute(let attr):
                    if attr.attributeName.tokens(viewMode: .all).map(\.tokenKind) == expectation {
                        return attr
                    }
                default:
                    break
            }
        }
        return nil
    }

    var arguments: [(String, String)] {
        signature.parameterClause.parameters.map { param in
            let label = param.firstName.text
            let type = param.type.trimmedDescription

            return (label, type)
        }
    }
}

extension ExprSyntax {
    var asString: String? {
        guard let str = self.as(StringLiteralExprSyntax.self) else { return nil }
        return str.representedLiteralValue
    }

    var asStringArray: [String]? {
        guard let arr = self.as(ArrayExprSyntax.self) else { return nil }
        return arr.elements.compactMap(\.expression.asString)
    }
}

struct HTTPMethod: Hashable {
    let pattern: String?
    let method: `Type`

    var parameters: [String] {
        pattern?
            .split(separator: "/")
            .filter { $0.hasPrefix(":") }
            .map { String($0.dropFirst()) }
            ?? []
    }

    func illegalParameters(for arguments: [(String, String)]) -> [String] {
        parameters.filter { parameter in
            parameter == "body" || arguments.contains {
                $0.0 == parameter && ( $0.1.isContext || $0.1.isRequest)
            }
        }
    }

    func unusedParameters(for arguments: [(String, String)]) -> [String] {
        let illegalParameters = illegalParameters(for: arguments)
        return parameters.filter { parameter in
            !illegalParameters.contains(parameter) && !arguments.contains {
                $0.0 == parameter
            }
        }
    }

    func reportIllegalParameters(
        for arguments: [(String, String)],
        using context: some MacroExpansionContext
    ) {
        for illegal in illegalParameters(for: arguments) {
            context.diagnose(.init(node: attributeNode, message: Message(
                message: "Use of forbidden path parameter: '\(illegal)' is not allowed in this context. It is already reserved.",
                id: "use-of-forbidden-path-parameter",
                severity: .error
            )))
        }

        let declaredAsQueryParam = parameters.filter { parameter in
            arguments.contains {
                $0.0 == parameter && ( $0.1.typeAllowsQueryParameter )
            }
        }

        for queryParam in declaredAsQueryParam {
            context.diagnose(.init(node: attributeNode, message: Message(
                message: "Path parameter '\(queryParam)' declared as optional on the function. Path parameters cannot be optional. Make it non-optional or use a wildcard instead to use it as query parameter.",
                id: "use-of-forbidden-path-parameter",
                severity: .error
            )))
        }
    }

    func warnUnusedParameters(
        for arguments: [(String, String)],
        using context: some MacroExpansionContext
    ) {
        for unused in unusedParameters(for: arguments) {
            context.diagnose(.init(node: attributeNode, message: Message(
                message: "Unused path parameter: '\(unused)'. Consider using a wildcard instead.",
                id: "unused-path-parameter",
                severity: .warning
            )))
        }
    }

    var attributeNode: AttributeSyntax

    init?(_ node: AttributeSyntax) {
        guard
            let type = Type(string: node.attributeName.trimmedDescription)
        else { return nil }

        self.method = type
        self.attributeNode = node

        guard let args = node.arguments?.as(LabeledExprListSyntax.self)
        else {
            self.pattern = nil
            return
        }

        guard !args.contains(where: {
            $0.label?.text != "pattern"
        }) else {
            return nil
        }

        if
            let pattern = args.first(where: { $0.label?.text == "pattern" }),
            let patternString = pattern.expression.asString
        {
            self.pattern = patternString
        } else {
            self.pattern = nil
        }
    }

    enum `Type`: String {
        init?(string: String) {
            switch string {
                case "GET": self = .get
                case "PATCH": self = .patch
                case "POST": self = .post
                case "DELETE": self = .delete
                default: return nil
            }
        }
        case get, patch, post, delete

        var asEnumString: String {
            rawValue.lowercased()
        }
    }
}

extension String {
    var typeAllowsPathParameter: Bool {
        self.last != "?" && !self.hasPrefix("Optional<")
            && self != "Request" && self != "any RequestContext"
    }

    var typeAllowsQueryParameter: Bool {
        self.last == "?" || self.hasPrefix("Optional<")
            && self != "Request" && self != "any RequestContext"
    }

    var isRequest: Bool {
        self == "Request"
    }

    var isContext: Bool {
        self == "any RequestContext"
    }
}
