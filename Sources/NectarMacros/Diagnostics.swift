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
