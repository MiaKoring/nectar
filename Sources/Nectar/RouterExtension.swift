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
    public func registerNectarApp(_ app: NectarApp) throws(EndpointAdditionError) {
        for endpoint in app.endpoints {
            try endpoint.build(into: self.group(), currentURI: "")
        }
    }
}
