import Foundation

struct LogEntry: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let isAlert: Bool
}
