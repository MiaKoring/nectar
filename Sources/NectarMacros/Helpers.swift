import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion
import SwiftDiagnostics
import SwiftBasicFormat

extension StructDeclSyntax {
    func endpoints(context _: some MacroExpansionContext) -> [ExprSyntax] {
        let functions = memberBlock.members
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
        
        var endpoints = [ExprSyntax]()
        
        for function in functions {
            guard let method = function.httpMethod else { continue }
            
            let arguments = function.arguments
            
            let pathParameters = arguments.filter { (name, type) in
                name != "body" && type.typeAllowsPathParameter
            }.map { ":\($0.0)" }
            
            let partialPath = method.pattern
            ?? pathParameters.joined(separator: "/")
            
            let name = function.name.text
            
            endpoints.append(
                """
                Endpoint(
                    partialPath: \(literal: partialPath),
                    httpMethod: .\(raw: method.method),
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
        guard let method = httpMethod else { return nil }
        
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
        let tryClause = signature.effectSpecifiers?.throwsClause?.throwsSpecifier != nil ? "try " : ""
        
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
        ["GET", "SET", "POST", "PATCH"]
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
    
    init?(_ node: AttributeSyntax) {
        guard
            let type = Type(string: node.attributeName.trimmedDescription)
        else { return nil }
        
        self.method = type
        
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
