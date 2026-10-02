import Foundation

enum Relation: String, Codable {
    case mother = "Mother"
    case father = "Father"
    case brother = "Brother"
    case sister = "Sister"
}

struct FamilyMember: Identifiable, Codable {
    let id = UUID()
    var name: String
    var relation: Relation
    var relationship: Int
    var isAlive: Bool = true
    var history: RelationshipHistory = RelationshipHistory()

    mutating func adjustRelationship(_ delta: Int, ceiling: Int = 100) {
        let cap = delta > 0 ? ceiling : 100
        relationship = min(cap, max(0, relationship + delta))
    }

    var gender: Gender {
        switch relation {
        case .mother, .sister: return .female
        case .father, .brother: return .male
        }
    }

    var avatarStage: LifeStage {
        switch relation {
        case .mother, .father: return .adult
        case .brother, .sister: return .teen
        }
    }
}
