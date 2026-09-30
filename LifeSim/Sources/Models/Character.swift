import Foundation

enum Gender: String {
    case male = "Male"
    case female = "Female"
}

struct Character {
    var firstName: String
    var lastName: String
    var gender: Gender
    var country: String
    var age: Int = 0
    var stats: Stats
    var family: [FamilyMember]
    var friends: [Friend] = []
    var conditions: [ActiveCondition] = []
    var isAlive: Bool = true
    var causeOfDeath: String?

    var cash: Int = 0
    var ownedAccessoryIDs: Set<String> = []
    var equippedAccessoryIDs: [AccessorySlot: String] = [:]

    var educationLevel: EducationLevel = .none
    var universityName: String?
    var job: Job?
    var yearsAtJob: Int = 0

    /// Permanent marks left by serious injuries or surgeries. Doesn't heal
    /// even after the underlying condition is treated. Capped visually.
    var scars: Int = 0

    var fullName: String { "\(firstName) \(lastName)" }
    var stage: LifeStage { LifeStage.forAge(age) }
    var equippedAccessories: [Accessory] {
        equippedAccessoryIDs.values.compactMap { AccessoryData.byID[$0] }
    }
    var isWearingCorrectiveGlasses: Bool {
        guard let faceID = equippedAccessoryIDs[.face] else { return false }
        return AccessoryData.byID[faceID]?.isCorrective ?? false
    }
    var hasUncorrectedVision: Bool {
        conditions.contains { $0.conditionID == "poor_vision" } && !isWearingCorrectiveGlasses
    }
}
