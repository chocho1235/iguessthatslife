import Foundation

struct Friend: Identifiable {
    let id = UUID()
    var name: String
    var gender: Gender
    var relationship: Int

    mutating func adjustRelationship(_ delta: Int) {
        relationship = min(100, max(0, relationship + delta))
    }
}

enum PersonRef: Hashable {
    case family(UUID)
    case friend(UUID)
}
