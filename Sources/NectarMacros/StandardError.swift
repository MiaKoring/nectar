import Foundation

struct StandardError: TextOutputStream {
    mutating func write(_ string: String) {
        fputs(string, stderr)
    }
}
