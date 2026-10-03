import Foundation

/// How serious a charge is. Drives the sentence, how many points land on
/// your record if convicted, and how much a lawyer charges to fight it.
enum ChargeSeverity: Int, Comparable {
    case misdemeanor = 0
    case felony = 1
    case seriousFelony = 2
    case capital = 3

    static func < (lhs: ChargeSeverity, rhs: ChargeSeverity) -> Bool { lhs.rawValue < rhs.rawValue }

    var label: String {
        switch self {
        case .misdemeanor: return "Misdemeanor"
        case .felony: return "Felony"
        case .seriousFelony: return "Serious Felony"
        case .capital: return "Capital Offense"
        }
    }

    /// Points added to the criminal record — only ever on a conviction.
    var recordPoints: Int {
        switch self {
        case .misdemeanor: return 1
        case .felony: return 2
        case .seriousFelony: return 4
        case .capital: return 8
        }
    }

    /// US-pegged fee ranges, scaled to the local economy when a case opens.
    var privateLawyerRange: ClosedRange<Int> {
        switch self {
        case .misdemeanor: return 7_000...12_000
        case .felony: return 20_000...35_000
        case .seriousFelony: return 45_000...80_000
        case .capital: return 90_000...150_000
        }
    }

    var topAttorneyMultiplier: Double { 3.5 }

    /// Zero means bail is denied outright.
    var bailRange: ClosedRange<Int> {
        switch self {
        case .misdemeanor: return 500...1_500
        case .felony: return 5_000...15_000
        case .seriousFelony: return 25_000...75_000
        case .capital: return 0...0
        }
    }
}

enum CrimeType: String, Codable, CaseIterable {
    case shoplifting
    case pickpocketing
    case burglary
    case carTheft
    case armedRobbery
    case bankRobbery
    case assault
    case attemptedMurder
    case murder
    case murderForHire
    case conspiracyToMurder
    case weaponPossession
    case weaponSmuggling

    var displayName: String {
        switch self {
        case .shoplifting: return "Shoplifting"
        case .pickpocketing: return "Theft"
        case .burglary: return "Burglary"
        case .carTheft: return "Grand Theft Auto"
        case .armedRobbery: return "Armed Robbery"
        case .bankRobbery: return "Bank Robbery"
        case .assault: return "Assault"
        case .attemptedMurder: return "Attempted Murder"
        case .murder: return "Murder"
        case .murderForHire: return "Murder for Hire"
        case .conspiracyToMurder: return "Conspiracy to Commit Murder"
        case .weaponPossession: return "Illegal Weapon Possession"
        case .weaponSmuggling: return "Weapon Smuggling"
        }
    }

    var severity: ChargeSeverity {
        switch self {
        case .shoplifting, .pickpocketing, .weaponPossession: return .misdemeanor
        case .burglary, .carTheft, .assault, .weaponSmuggling: return .felony
        case .armedRobbery, .bankRobbery, .attemptedMurder, .conspiracyToMurder: return .seriousFelony
        case .murder, .murderForHire: return .capital
        }
    }

    /// Prison years on a full conviction. A zero means probation is possible.
    var sentenceRange: ClosedRange<Int> {
        switch self {
        case .shoplifting: return 0...0
        case .pickpocketing: return 0...1
        case .weaponPossession: return 0...2
        case .burglary: return 1...4
        case .carTheft: return 1...3
        case .assault: return 1...5
        case .weaponSmuggling: return 2...6
        case .armedRobbery: return 3...8
        case .bankRobbery: return 5...12
        case .conspiracyToMurder: return 6...15
        case .attemptedMurder: return 8...20
        case .murder: return 20...45
        case .murderForHire: return 25...50
        }
    }

    var fineRange: ClosedRange<Int> {
        switch severity {
        case .misdemeanor: return 200...900
        case .felony: return 1_000...5_000
        case .seriousFelony: return 5_000...20_000
        case .capital: return 10_000...40_000
        }
    }

    /// How strong the case tends to be before anything else is factored in.
    var baseEvidence: Double {
        switch self {
        case .shoplifting: return 0.55
        case .pickpocketing: return 0.45
        case .burglary: return 0.45
        case .carTheft: return 0.5
        case .armedRobbery: return 0.5
        case .bankRobbery: return 0.6
        case .assault: return 0.55
        case .attemptedMurder: return 0.55
        case .murder: return 0.45
        case .murderForHire: return 0.4
        case .conspiracyToMurder: return 0.75
        case .weaponPossession: return 0.85
        case .weaponSmuggling: return 0.85
        }
    }

    /// Murder has no statute of limitations — those cases never go cold.
    var neverGoesCold: Bool { self == .murder || self == .murderForHire }
}

/// An unsolved crime the police are still working. Each year it might lead
/// back to you, until it eventually goes cold.
struct OpenCase: Codable, Hashable {
    var crime: CrimeType
    var yearsOpen: Int = 0
}

struct LegalTrouble: Identifiable {
    let id = UUID()
    let charges: [CrimeType]
    /// 0...1 — how solid the prosecution's case is.
    let evidence: Double
    /// Zero means bail was denied.
    let bailAmount: Int
    /// What a bail bondsman keeps for posting the bail for you.
    let bondsmanFee: Int
    let privateLawyerCost: Int
    let topAttorneyCost: Int
    /// The weapon police took off you when you were arrested, if any.
    let seizedWeapon: String?
    /// Short line explaining how the arrest happened.
    let arrestStory: String

    var leadCharge: CrimeType {
        charges.max { $0.severity < $1.severity } ?? .pickpocketing
    }

    var chargeDescription: String {
        charges.map(\.displayName).joined(separator: " + ")
    }

    var bailDenied: Bool { bailAmount == 0 }

    var evidenceLabel: String {
        switch evidence {
        case ..<0.4: return "Weak"
        case ..<0.6: return "Moderate"
        case ..<0.8: return "Strong"
        default: return "Overwhelming"
        }
    }
}

enum LawyerOption: CaseIterable, Identifiable {
    case selfRepresented
    case publicDefender
    case privateLawyer
    case topAttorney

    var id: Self { self }

    var title: String {
        switch self {
        case .selfRepresented: return "Represent Yourself"
        case .publicDefender: return "Public Defender"
        case .privateLawyer: return "Private Lawyer"
        case .topAttorney: return "Top Defense Attorney"
        }
    }

    var blurb: String {
        switch self {
        case .selfRepresented: return "No lawyer, no advice. Just you against the prosecutor."
        case .publicDefender: return "Free, but overworked. Their advice is a coin flip some days."
        case .privateLawyer: return "Solid lawyer with honest advice and a real shot at a win."
        case .topAttorney: return "The best money can buy. Tears weak cases apart and never misreads one."
        }
    }

    var icon: String {
        switch self {
        case .selfRepresented: return "person.fill"
        case .publicDefender: return "person.fill.questionmark"
        case .privateLawyer: return "briefcase.fill"
        case .topAttorney: return "crown.fill"
        }
    }

    /// Who shows up in the courtroom cutscene.
    var lawyerName: String? {
        switch self {
        case .selfRepresented: return nil
        case .publicDefender: return "Dale Hicks"
        case .privateLawyer: return "Maria Castillo"
        case .topAttorney: return "Victor Sterling"
        }
    }

    var lawyerGender: Gender {
        self == .privateLawyer ? .female : .male
    }

    /// Scales the evidence into a conviction chance at trial.
    var evidenceWeight: Double {
        switch self {
        case .selfRepresented: return 1.15
        case .publicDefender: return 1.0
        case .privateLawyer: return 0.7
        case .topAttorney: return 0.4
        }
    }

    /// How much of the full sentence is handed down if found guilty at trial.
    var sentenceMultiplier: Double {
        switch self {
        case .selfRepresented: return 1.1
        case .publicDefender: return 1.0
        case .privateLawyer: return 0.8
        case .topAttorney: return 0.6
        }
    }

    /// How often their plea advice is actually the smart call.
    var adviceAccuracy: Double {
        switch self {
        case .selfRepresented: return 0
        case .publicDefender: return 0.65
        case .privateLawyer: return 0.85
        case .topAttorney: return 0.97
        }
    }
}

/// What your lawyer whispers to you before the judge asks for your plea.
struct LawyerAdvice {
    let recommendsGuilty: Bool
    let line: String
}

struct CourtVerdict {
    let guilty: Bool
    let years: Int
    let fine: Int
    let recordPoints: Int
    let headline: String
    let summary: String
}
