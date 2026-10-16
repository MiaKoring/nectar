// ===----------------------------------------------------------------------===
//
// This source file is part of the Nectar open source project
//
// Copyright (c) 2026 Mia Koring.
//
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===

import Hummingbird
public protocol EndpointGroup {
    var _endpoints: [Endpoint] { get }
    var partialName: String { get }
    @EndpointBuilder
    var subgroups: [any EndpointGroup] { get }
    
    func addMiddlewares<C: RequestContext>(to group: RouterGroup<C>) -> RouterGroup<C>
}

extension EndpointGroup {
    public var subgroups: [any EndpointGroup] {
        []
    }
    
    public func addMiddlewares<C: RequestContext>(to group: RouterGroup<C>) -> RouterGroup<C> {
        group
    }
    
    public func build<C: RequestContext>(into group: RouterGroup<C>, currentURI: String) throws(EndpointAdditionError) {
        let currentURI = currentURI + (partialName.isEmpty ? "": "/" + partialName)
        var group = group.group("\(partialName)")
        
        group = addMiddlewares(to: group)
        
        for subgroup in subgroups {
            try subgroup.build(into: group, currentURI: currentURI)
        }
        
        for endpoint in _endpoints {
            if !endpoint.pathParams.isEmpty {
                let currentURI = currentURI + (endpoint.partialPath.isEmpty ? "": "/" + endpoint.partialPath)
                let splitURI = currentURI.split(separator: "/")
                
                for param in endpoint.pathParams {
                    if !splitURI.contains(where: { $0 == ":" + param }) {
                        throw EndpointAdditionError.missingPathParameter(param, currentURI)
                    }
                }
            }
            
            switch endpoint.httpMethod {
                case .get:
                    group.get(RouterPath(endpoint.partialPath), use: endpoint.handler)
                case .patch:
                    group.patch(RouterPath(endpoint.partialPath), use: endpoint.handler)
                case .post:
                    group.post(RouterPath(endpoint.partialPath), use: endpoint.handler)
                case .delete:
                    group.delete(RouterPath(endpoint.partialPath), use: endpoint.handler)
            }
        }
    }
}
