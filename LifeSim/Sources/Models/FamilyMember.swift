import Foundation

enum Relation: String, Codable {
    case mother = "Mother"
    case father = "Father"
    case brother = "Brother"
    case sister = "Sister"
    case son = "Son"
    case daughter = "Daughter"
}

struct FamilyMember: Identifiable, Codable {
    let id = UUID()
    var name: String
    var relation: Relation
    var relationship: Int
    var isAlive: Bool = true
    var history: RelationshipHistory = RelationshipHistory()
    /// Only meaningful for sons/daughters — everyone else uses a fixed
    /// `avatarStage` since the game doesn't track parents'/siblings' ages.
    var age: Int = 0

    mutating func adjustRelationship(_ delta: Int, ceiling: Int = 100) {
        let cap = delta > 0 ? ceiling : 100
        relationship = min(cap, max(0, relationship + delta))
    }

    var isOwnChild: Bool { relation == .son || relation == .daughter }

    var gender: Gender {
        switch relation {
        case .mother, .sister, .daughter: return .female
        case .father, .brother, .son: return .male
        }
    }

    var avatarStage: LifeStage {
        switch relation {
        case .mother, .father: return .adult
        case .brother, .sister: return .teen
        case .son, .daughter: return LifeStage.forAge(age)
        }
    }
}
