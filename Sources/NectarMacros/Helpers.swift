import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion
import SwiftDiagnostics

extension StructDeclSyntax {
    func endpoints(context: some MacroExpansionContext) -> [ExprSyntax] {
        var logger = StandardError()
        
        let functions = memberBlock.members
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
        
        context.diagnose(.init(node: self, message: Message(message: "functions: \(functions.filter{ $0.httpMethod != nil }.count)", id: "lol", severity: .warning)))
        
        var endpoints = [ExprSyntax]()
        
        for function in functions {
            guard let method = function.httpMethod else { continue }
            
            let arguments = function.arguments
            
            let pathParameters = arguments.filter { (name, _) in
                name != "body" && !method.queryParams.contains(name)
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
}

extension FunctionDeclSyntax {
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
    let queryParams: [String]
    let method: `Type`
    
    init?(_ node: AttributeSyntax) {
        guard
            let type = Type(string: node.attributeName.trimmedDescription)
        else { return nil }
        
        self.method = type
        
        guard let args = node.arguments?.as(LabeledExprListSyntax.self)
        else {
            self.pattern = nil
            self.queryParams = []
            return
        }
        
        guard !args.contains(where: {
            $0.label?.text != "pattern"
            && $0.label?.text != "queryParams"
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
        
        if
            let queryParams = args.first(where: { $0.label?.text == "queryParams"}),
            let params = queryParams.expression.asStringArray
        {
            self.queryParams = params
        } else {
            self.queryParams = []
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
