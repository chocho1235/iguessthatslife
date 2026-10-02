import Foundation

struct Partner: Codable {
    var name: String
    var gender: Gender
    var relationship: Int
    var isMarried: Bool = false
    var yearsTogether: Int = 0
    var history: RelationshipHistory = RelationshipHistory()

    mutating func adjustRelationship(_ delta: Int, ceiling: Int = 100) {
        let cap = delta > 0 ? ceiling : 100
        relationship = min(cap, max(0, relationship + delta))
    }
}
