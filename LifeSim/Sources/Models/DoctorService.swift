import Foundation

enum DoctorService: String, CaseIterable, Identifiable {
    case checkup = "Checkup"
    case treatment = "Treatment"
    case surgery = "Surgery"

    var id: String { rawValue }

    var cost: Int {
        switch self {
        case .checkup: return 10
        case .treatment: return 40
        case .surgery: return 100
        }
    }

    var healRange: ClosedRange<Int> {
        switch self {
        case .checkup: return 3...8
        case .treatment: return 15...25
        case .surgery: return 30...45
        }
    }

    var blurb: String {
        switch self {
        case .checkup: return "A quick check-up and some friendly advice."
        case .treatment: return "Proper treatment for what's ailing you."
        case .surgery: return "A serious operation for serious problems. Small risk of complications."
        }
    }

    var icon: String {
        switch self {
        case .checkup: return "stethoscope"
        case .treatment: return "cross.case.fill"
        case .surgery: return "bandage.fill"
        }
    }
}
