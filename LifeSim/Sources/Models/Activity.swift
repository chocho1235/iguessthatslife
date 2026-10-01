import Foundation

enum ActivityKind: String, CaseIterable, Identifiable {
    case gym = "Hit the Gym"
    case reading = "Read a Book"
    case volunteering = "Volunteer Locally"
    case meditating = "Meditate"
    case hobby = "Work on a Hobby"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .gym: return "figure.strengthtraining.traditional"
        case .reading: return "book.fill"
        case .volunteering: return "heart.fill"
        case .meditating: return "leaf.fill"
        case .hobby: return "paintpalette.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .gym: return "Boosts happiness and looks."
        case .reading: return "Boosts smarts."
        case .volunteering: return "Boosts happiness and a family relationship."
        case .meditating: return "Boosts happiness."
        case .hobby: return "Boosts happiness, maybe smarts or looks too."
        }
    }
}
