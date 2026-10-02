import Foundation

enum Suit: String, CaseIterable {
    case spades = "♠"
    case hearts = "♥"
    case diamonds = "♦"
    case clubs = "♣"

    var isRed: Bool { self == .hearts || self == .diamonds }
}

enum Rank: Int, CaseIterable {
    case two = 2, three, four, five, six, seven, eight, nine, ten
    case jack, queen, king, ace

    var label: String {
        switch self {
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        case .ace: return "A"
        default: return "\(rawValue)"
        }
    }

    var blackjackValue: Int {
        switch self {
        case .jack, .queen, .king: return 10
        case .ace: return 11
        default: return rawValue
        }
    }
}

struct Card: Identifiable, Equatable {
    let id = UUID()
    let suit: Suit
    let rank: Rank
}

enum BlackjackOutcome {
    case blackjack
    case win
    case push
    case lose
}

/// Pure hand-evaluation logic, kept separate from the view so the dealing
/// and scoring rules don't get tangled up with layout code.
enum BlackjackHand {
    static func freshShuffledDeck() -> [Card] {
        Suit.allCases.flatMap { suit in Rank.allCases.map { Card(suit: suit, rank: $0) } }.shuffled()
    }

    /// Totals the hand, counting aces as 11 and quietly downgrading them to 1
    /// one at a time until the hand no longer busts (or runs out of aces).
    static func value(of cards: [Card]) -> Int {
        var total = cards.reduce(0) { $0 + $1.rank.blackjackValue }
        var aces = cards.filter { $0.rank == .ace }.count
        while total > 21, aces > 0 {
            total -= 10
            aces -= 1
        }
        return total
    }

    static func isBust(_ cards: [Card]) -> Bool { value(of: cards) > 21 }

    static func isNatural(_ cards: [Card]) -> Bool { cards.count == 2 && value(of: cards) == 21 }
}
