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

extension Router {
    public func registerNectarApp(_ app: NectarApp) {
        for endpoint in app.endpoints {
            switch endpoint.httpMethod {
                case .get:
                    self.get(RouterPath(endpoint.partialPath), use: endpoint.handler)
                case .patch:
                    self.patch(RouterPath(endpoint.partialPath), use: endpoint.handler)
                case .post:
                    self.post(RouterPath(endpoint.partialPath), use: endpoint.handler)
                case .delete:
                    self.delete(RouterPath(endpoint.partialPath), use: endpoint.handler)
            }
        }
    }
}
