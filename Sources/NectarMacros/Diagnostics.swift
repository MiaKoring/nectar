// ===----------------------------------------------------------------------===
//
// This source file is part of the Nectar open source project
//
// Copyright (c) 2026 Mia Koring.
//
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===

import SwiftDiagnostics

struct Message: DiagnosticMessage {
    let message: String

    let diagnosticID: SwiftDiagnostics.MessageID

    let severity: SwiftDiagnostics.DiagnosticSeverity

    init(message: String, id: String, severity: SwiftDiagnostics.DiagnosticSeverity) {
        self.message = message
        self.diagnosticID = .init(domain: "de.amethystsoft.nectar", id: id)
        self.severity = severity
    }
}
