import Foundation

enum Gender: String, Codable {
    case male = "Male"
    case female = "Female"
}

struct Character: Codable {
    var firstName: String
    var lastName: String
    var gender: Gender
    var country: String
    var age: Int = 0
    var stats: Stats
    var family: [FamilyMember]
    var friends: [Friend] = []
    var partner: Partner? = nil
    var ownedAssetIDs: Set<String> = []
    var conditions: [ActiveCondition] = []
    var isAlive: Bool = true
    var causeOfDeath: String?

    var cash: Int = 0
    var bankBalance: Int = 0
    var stockHoldings: [String: Int] = [:]
    var stockPrices: [String: Double] = [:]
    var ownedAccessoryIDs: Set<String> = []
    var equippedAccessoryIDs: [AccessorySlot: String] = [:]
    var ownedOutfitIDs: Set<String> = ["basic_tee"]
    var equippedOutfitID: String? = "basic_tee"

    var educationLevel: EducationLevel = .none
    var universityName: String?
    var job: Job?
    var yearsAtJob: Int = 0

    /// Permanent marks left by serious injuries or surgeries. Doesn't heal
    /// even after the underlying condition is treated. Capped visually.
    var scars: Int = 0
    var gangName: String?
    var weaponName: String?
    /// Points from actual court convictions only. Committing a crime and
    /// getting away with it never touches this.
    var criminalRecord: Int = 0
    /// Stored as optionals so saves from before these existed still load.
    var convictionList: [String]? = nil
    var policeHeatValue: Int? = nil
    var openCaseList: [OpenCase]? = nil
    /// How many robberies this character has attempted — the police get
    /// better at catching up with you the more you push your luck.
    var robberyCount: Int = 0
    /// Years left to serve — while this is above zero, ageUp() runs the
    /// prison year track instead of ordinary civilian life.
    var jailYearsRemaining: Int = 0
    /// Set by a successful jailbreak. Never cleared automatically — it makes
    /// the world a little more hostile for the rest of the character's life.
    var isFugitive: Bool = false

    var fullName: String { "\(firstName) \(lastName)" }
    var convictions: [String] {
        get { convictionList ?? [] }
        set { convictionList = newValue }
    }
    /// 0...100 — how hard the police are looking at you right now. Rises
    /// with every crime, cools off a little each year.
    var policeHeat: Int {
        get { policeHeatValue ?? 0 }
        set { policeHeatValue = min(100, max(0, newValue)) }
    }
    var openCases: [OpenCase] {
        get { openCaseList ?? [] }
        set { openCaseList = newValue }
    }
    var hasCriminalRecord: Bool { criminalRecord > 0 }
    var isMasked: Bool { equippedAccessoryIDs[.face] == "balaclava" }
    var weapon: Weapon? { weaponName.flatMap { name in WeaponData.all.first { $0.name == name } } }
    var stage: LifeStage { LifeStage.forAge(age) }
    var isInJail: Bool { jailYearsRemaining > 0 }
    var equippedAccessories: [Accessory] {
        equippedAccessoryIDs.values.compactMap { AccessoryData.byID[$0] }
    }
    var equippedOutfit: Outfit? {
        equippedOutfitID.flatMap { OutfitData.byID[$0] }
    }
    var isWearingCorrectiveGlasses: Bool {
        guard let faceID = equippedAccessoryIDs[.face] else { return false }
        return AccessoryData.byID[faceID]?.isCorrective ?? false
    }
    var hasUncorrectedVision: Bool {
        conditions.contains { $0.conditionID == "poor_vision" } && !isWearingCorrectiveGlasses
    }
}
