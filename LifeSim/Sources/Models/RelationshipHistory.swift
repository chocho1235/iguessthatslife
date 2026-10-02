import Foundation

/// Tracks how a relationship has actually been treated — not just its
/// current number — so interactions can't be spammed for free, repeated
/// abuse has real consequences, and the same action feels different
/// depending on mood and history.
struct RelationshipHistory: Codable {
    /// How many times each action (by its string key) has been used this
    /// life-year. Reset every `ageUp()`.
    private var actionsThisYear: [String: Int] = [:]
    /// Builds up from begging, pranking, arguing, and stealing. High
    /// resentment caps how far relationship can recover and raises the
    /// chance of a backlash.
    var resentment: Int = 0
    /// Re-rolled each year — a bad year makes every positive action land
    /// softer and every negative one land harder.
    var moodRoll: Int = Int.random(in: 30...80)

    /// Total budgeted interactions allowed per person per year, shared
    /// across all action kinds so variety is rewarded over spamming one.
    static let yearlyBudget = 3

    var usedThisYear: Int { actionsThisYear.values.reduce(0, +) }
    var remainingThisYear: Int { max(0, Self.yearlyBudget - usedThisYear) }

    func uses(of action: String) -> Int { actionsThisYear[action] ?? 0 }

    mutating func recordUse(_ action: String) {
        actionsThisYear[action, default: 0] += 1
    }

    mutating func resetYearly() {
        actionsThisYear = [:]
        moodRoll = Int.random(in: 20...90)
        // Resentment cools off slowly if left alone rather than vanishing,
        // so a pattern of abuse still has to be earned back.
        resentment = max(0, resentment - Int.random(in: 3...8))
    }

    /// Repeating the exact same action back-to-back in one year earns less
    /// each time — the 1st use is full strength, the 4th barely registers.
    func diminishingMultiplier(for action: String) -> Double {
        switch uses(of: action) {
        case 0: return 1.0
        case 1: return 0.55
        case 2: return 0.28
        default: return 0.12
        }
    }

    /// Scales positive or negative effects based on this year's mood roll.
    func moodMultiplier(positive: Bool) -> Double {
        if moodRoll < 35 {
            return positive ? 0.65 : 1.35
        } else if moodRoll > 70 {
            return positive ? 1.25 : 0.8
        }
        return 1.0
    }

    var isInBadMood: Bool { moodRoll < 35 }
    var isInGreatMood: Bool { moodRoll > 70 }

    /// Resentment pulls the ceiling on how high relationship can climb back
    /// to — you can't just buy your way back to best-friends after enough
    /// mooching and stealing.
    var relationshipCeiling: Int { max(40, 100 - resentment) }

    mutating func addResentment(_ amount: Int) {
        resentment = min(100, resentment + amount)
    }
}
