import Foundation

enum ConditionSeverity: String {
    case mild = "Mild"
    case moderate = "Moderate"
    case severe = "Severe"

    var requiredService: DoctorService {
        switch self {
        case .mild: return .checkup
        case .moderate: return .treatment
        case .severe: return .surgery
        }
    }
}

struct Condition {
    let id: String
    let name: String
    let severity: ConditionSeverity
    let stages: Set<LifeStage>
    let healthDrain: Int
    let happinessDrain: Int
    let naturalRecoveryChance: Double
    /// Vision conditions aren't cured at the doctor — they're corrected by
    /// wearing glasses, and stay in the character's condition list forever.
    let requiresGlasses: Bool
    /// Catastrophic injuries (stabbings, gunshots) cost far more than a
    /// standard surgery — this overrides `severity.requiredService.cost`.
    let customTreatmentCost: Int?

    init(id: String, name: String, severity: ConditionSeverity, stages: Set<LifeStage>, healthDrain: Int, happinessDrain: Int, naturalRecoveryChance: Double, requiresGlasses: Bool = false, customTreatmentCost: Int? = nil) {
        self.id = id
        self.name = name
        self.severity = severity
        self.stages = stages
        self.healthDrain = healthDrain
        self.happinessDrain = happinessDrain
        self.naturalRecoveryChance = naturalRecoveryChance
        self.requiresGlasses = requiresGlasses
        self.customTreatmentCost = customTreatmentCost
    }

    var treatmentCost: Int { customTreatmentCost ?? severity.requiredService.cost }
}

struct ActiveCondition: Identifiable, Codable {
    let id = UUID()
    let conditionID: String
    var isDiagnosed: Bool = false
    var yearsAfflicted: Int = 0
}

enum ConditionData {
    static let all: [Condition] = [
        // Common illnesses
        Condition(id: "infant_fever", name: "Infant Fever", severity: .mild, stages: [.infant], healthDrain: 3, happinessDrain: 2, naturalRecoveryChance: 0.4),
        Condition(id: "cold", name: "Common Cold", severity: .mild, stages: [.infant, .child, .teen, .adult, .senior], healthDrain: 2, happinessDrain: 1, naturalRecoveryChance: 0.35),
        Condition(id: "ear_infection", name: "Ear Infection", severity: .mild, stages: [.infant, .child], healthDrain: 2, happinessDrain: 2, naturalRecoveryChance: 0.3),
        Condition(id: "chickenpox", name: "Chickenpox", severity: .moderate, stages: [.child], healthDrain: 3, happinessDrain: 3, naturalRecoveryChance: 0.25),
        Condition(id: "strep_throat", name: "Strep Throat", severity: .mild, stages: [.child, .teen], healthDrain: 2, happinessDrain: 2, naturalRecoveryChance: 0.3),
        Condition(id: "flu", name: "Flu", severity: .moderate, stages: [.child, .teen, .adult, .senior], healthDrain: 4, happinessDrain: 2, naturalRecoveryChance: 0.2),
        Condition(id: "stomach_bug", name: "Stomach Bug", severity: .mild, stages: [.child, .teen, .adult, .senior], healthDrain: 3, happinessDrain: 2, naturalRecoveryChance: 0.4),
        Condition(id: "food_poisoning", name: "Food Poisoning", severity: .moderate, stages: [.teen, .adult, .senior], healthDrain: 5, happinessDrain: 2, naturalRecoveryChance: 0.35),
        Condition(id: "bronchitis", name: "Bronchitis", severity: .moderate, stages: [.adult, .senior], healthDrain: 4, happinessDrain: 2, naturalRecoveryChance: 0.2),
        Condition(id: "asthma", name: "Asthma", severity: .mild, stages: [.child, .teen, .adult], healthDrain: 2, happinessDrain: 1, naturalRecoveryChance: 0.1),
        Condition(id: "pneumonia", name: "Pneumonia", severity: .severe, stages: [.adult, .senior], healthDrain: 7, happinessDrain: 3, naturalRecoveryChance: 0.1),

        // Injuries
        Condition(id: "minor_injury", name: "Minor Injury", severity: .mild, stages: [.infant, .child, .teen, .adult, .senior], healthDrain: 2, happinessDrain: 2, naturalRecoveryChance: 0.3),
        Condition(id: "broken_arm", name: "Broken Arm", severity: .moderate, stages: [.child, .teen, .adult], healthDrain: 3, happinessDrain: 3, naturalRecoveryChance: 0.15),
        Condition(id: "pulled_muscle", name: "Pulled Muscle", severity: .mild, stages: [.teen, .adult, .senior], healthDrain: 2, happinessDrain: 1, naturalRecoveryChance: 0.35),
        Condition(id: "whiplash", name: "Whiplash", severity: .moderate, stages: [.teen, .adult], healthDrain: 3, happinessDrain: 2, naturalRecoveryChance: 0.2),
        Condition(id: "fall_injury", name: "Fall Injury", severity: .moderate, stages: [.adult, .senior], healthDrain: 4, happinessDrain: 2, naturalRecoveryChance: 0.15),
        Condition(id: "concussion", name: "Concussion", severity: .moderate, stages: [.child, .teen, .adult], healthDrain: 4, happinessDrain: 3, naturalRecoveryChance: 0.15),

        // Mental & chronic health
        Condition(id: "migraine", name: "Chronic Migraines", severity: .mild, stages: [.teen, .adult, .senior], healthDrain: 2, happinessDrain: 3, naturalRecoveryChance: 0.3),
        Condition(id: "insomnia", name: "Insomnia", severity: .mild, stages: [.teen, .adult], healthDrain: 1, happinessDrain: 4, naturalRecoveryChance: 0.25),
        Condition(id: "anxiety", name: "Anxiety", severity: .moderate, stages: [.teen, .adult], healthDrain: 1, happinessDrain: 5, naturalRecoveryChance: 0.2),
        Condition(id: "depression", name: "Depression", severity: .moderate, stages: [.teen, .adult, .senior], healthDrain: 2, happinessDrain: 6, naturalRecoveryChance: 0.12),
        Condition(id: "arthritis", name: "Arthritis", severity: .moderate, stages: [.senior], healthDrain: 3, happinessDrain: 2, naturalRecoveryChance: 0.05),
        Condition(id: "hypertension", name: "High Blood Pressure", severity: .severe, stages: [.adult, .senior], healthDrain: 5, happinessDrain: 1, naturalRecoveryChance: 0.05),
        Condition(id: "diabetes", name: "Diabetes", severity: .severe, stages: [.adult, .senior], healthDrain: 5, happinessDrain: 2, naturalRecoveryChance: 0.03),
        Condition(id: "heart_disease", name: "Heart Disease", severity: .severe, stages: [.senior], healthDrain: 8, happinessDrain: 3, naturalRecoveryChance: 0.02),
        Condition(id: "cancer", name: "Cancer", severity: .severe, stages: [.adult, .senior], healthDrain: 9, happinessDrain: 5, naturalRecoveryChance: 0.02),
        Condition(id: "appendicitis", name: "Appendicitis", severity: .severe, stages: [.child, .teen, .adult], healthDrain: 8, happinessDrain: 4, naturalRecoveryChance: 0.0),

        // Violent injuries — expensive emergency surgery, not a routine visit
        Condition(id: "stab_wound", name: "Stab Wound", severity: .severe, stages: [.teen, .adult, .senior], healthDrain: 10, happinessDrain: 6, naturalRecoveryChance: 0.0, customTreatmentCost: 32_000),
        Condition(id: "gunshot_wound", name: "Gunshot Wound", severity: .severe, stages: [.teen, .adult, .senior], healthDrain: 14, happinessDrain: 8, naturalRecoveryChance: 0.0, customTreatmentCost: 48_000),

        // Mysteries — hidden even in name until diagnosed at a checkup
        Condition(id: "mystery_rash", name: "Unexplained Rash", severity: .mild, stages: [.child, .teen, .adult, .senior], healthDrain: 2, happinessDrain: 2, naturalRecoveryChance: 0.3),
        Condition(id: "mystery_fatigue", name: "Unexplained Fatigue", severity: .moderate, stages: [.adult, .senior], healthDrain: 3, happinessDrain: 4, naturalRecoveryChance: 0.15),

        // Vision — corrected by wearing glasses, not by paying for treatment
        Condition(id: "poor_vision", name: "Poor Vision", severity: .mild, stages: [.child, .teen, .adult, .senior], healthDrain: 0, happinessDrain: 2, naturalRecoveryChance: 0.0, requiresGlasses: true),
    ]

    static let byID: [String: Condition] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

    static func randomCondition(for stage: LifeStage, excluding existing: Set<String>) -> Condition? {
        all.filter { $0.stages.contains(stage) && !existing.contains($0.id) }.randomElement()
    }
}
