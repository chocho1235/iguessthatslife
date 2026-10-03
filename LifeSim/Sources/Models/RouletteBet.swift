import Foundation

/// One square a chip can sit on. `payoutMultiple` is how many times the
/// stake comes back on a win, on top of the stake itself (so `35` on a
/// straight number returns 36x the chip in total).
enum RouletteBetKind: Hashable {
    case number(Int)
    case red, black
    case even, odd
    case low, high
    case dozen(Int)

    var payoutMultiple: Int {
        switch self {
        case .number: return 35
        case .dozen: return 2
        case .red, .black, .even, .odd, .low, .high: return 1
        }
    }

    func wins(for result: Int) -> Bool {
        switch self {
        case .number(let n): return n == result
        case .red: return RouletteNumbers.reds.contains(result)
        case .black: return result != 0 && !RouletteNumbers.reds.contains(result)
        case .even: return result != 0 && result % 2 == 0
        case .odd: return result != 0 && result % 2 == 1
        case .low: return (1...18).contains(result)
        case .high: return (19...36).contains(result)
        case .dozen(let d): return (1...36).contains(result) && (result - 1) / 12 == d - 1
        }
    }
}
