import Foundation

enum GambleGame: String, CaseIterable, Identifiable {
    case coinFlip = "Coin Flip"
    case diceRoll = "Dice Roll"
    case slots = "Slots"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .coinFlip: return "circle.lefthalf.filled"
        case .diceRoll: return "die.face.5.fill"
        case .slots: return "7.square.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .coinFlip: return "50/50 odds. Double your bet."
        case .diceRoll: return "Roll a 6 to win. 5x payout."
        case .slots: return "Long odds, huge payout. 8x if you hit it."
        }
    }

    var winChance: Double {
        switch self {
        case .coinFlip: return 0.5
        case .diceRoll: return 1.0 / 6.0
        case .slots: return 0.12
        }
    }

    var payoutMultiplier: Double {
        switch self {
        case .coinFlip: return 2.0
        case .diceRoll: return 5.0
        case .slots: return 8.0
        }
    }
}
