import CoreGraphics

enum RobberyDifficulty: CaseIterable {
    case lookout
    case standard
    case alert

    static func random() -> RobberyDifficulty { allCases.randomElement()! }

    var label: String {
        switch self {
        case .lookout: return "Distracted Mark"
        case .standard: return "Standard Mark"
        case .alert: return "Sharp-Eyed Mark"
        }
    }

    /// How fast the target patrols back and forth.
    var patrolSpeed: CGFloat {
        switch self {
        case .lookout: return 50
        case .standard: return 72
        case .alert: return 104
        }
    }

    var coneLength: CGFloat {
        switch self {
        case .lookout: return 115
        case .standard: return 150
        case .alert: return 188
        }
    }

    var coneHalfWidth: CGFloat {
        switch self {
        case .lookout: return 70
        case .standard: return 92
        case .alert: return 112
        }
    }

    /// How long the player can stay in the target's line of sight before
    /// being spotted.
    var graceSeconds: Double {
        switch self {
        case .lookout: return 1.4
        case .standard: return 1.0
        case .alert: return 0.6
        }
    }

    /// For house burglaries: scales how long before the homeowner returns.
    var homeownerPatience: Double {
        switch self {
        case .lookout: return 1.3
        case .standard: return 1.0
        case .alert: return 0.72
        }
    }
}

enum RobberyScenario: CaseIterable {
    case pickpocket
    case houseBurglary

    static func random() -> RobberyScenario { allCases.randomElement()! }

    /// Base seconds before a house burglary's homeowner comes home — scaled
    /// further by difficulty.
    var baseRiskDuration: Double {
        switch self {
        case .pickpocket: return 0
        case .houseBurglary: return 11
        }
    }
}

/// Decided once, before the mini-game launches, so the outcome (and whether
/// getting caught is merely risky or outright lethal) is locked in from the
/// start.
struct RobberySetup {
    let isMafiaBoss: Bool
    let difficulty: RobberyDifficulty
    let scenario: RobberyScenario
}
