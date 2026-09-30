import Foundation

enum Relation: String {
    case mother = "Mother"
    case father = "Father"
    case brother = "Brother"
    case sister = "Sister"
}

struct FamilyMember: Identifiable {
    let id = UUID()
    var name: String
    var relation: Relation
    var relationship: Int
    var isAlive: Bool = true

    mutating func adjustRelationship(_ delta: Int) {
        relationship = min(100, max(0, relationship + delta))
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
