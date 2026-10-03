import SwiftUI

/// One step on a career ladder.
struct CareerRank: Hashable {
    let title: String
    /// US-pegged yearly pay before the role's multiplier and local wages.
    let salary: Int
    /// Years you must spend in the rank below before this one opens up.
    let minYears: Int
    /// Performance (0...100) needed to be considered.
    let minPerformance: Int
    var requiresDegree = false
    var minSmarts = 0
}

/// A specialization inside a career, like Detective in the police or
/// Special Forces in the army.
struct CareerRole: Identifiable, Hashable {
    let id: String
    let title: String
    let summary: String
    let payMultiplier: Double
    /// 0...1 — how dangerous the work is. Drives injuries and deaths.
    let risk: Double
    /// Index into the track's ranks you must have reached to switch in.
    var minRank = 0
    var minSmarts = 0
    var minHealth = 0
    var requiresDegree = false
}

/// Something that might happen during a working year.
struct CareerYearEvent {
    let text: String
    let performance: Int
    let happiness: Int
}

struct CareerTrack: Identifiable {
    let id: String
    let name: String
    let icon: String
    let color: Color
    let summary: String
    let minAge: Int
    let maxJoinAge: Int
    var requiresDegree = false
    var minSmarts = 0
    var minHealth = 0
    /// Most criminal record points accepted. nil means no background check.
    let maxRecord: Int?
    /// 0...1 — base chance of being accepted when you apply.
    let acceptChance: Double
    let ranks: [CareerRank]
    let roles: [CareerRole]
    /// Roles you can pick on day one.
    var entryRoleIDs: [String]
    let goodEvents: [CareerYearEvent]
    let badEvents: [CareerYearEvent]
    /// How a dangerous year is described, e.g. "was deployed overseas".
    let dangerText: String
    /// Cause of death if a dangerous year goes fatally wrong.
    let deathCause: String

    func role(_ id: String) -> CareerRole? { roles.first { $0.id == id } }
    var jobID: String { "track_\(id)" }
}

/// Where the character is on a career ladder. Only counts while their
/// current job is the matching track job.
struct CareerProgress: Codable, Hashable {
    let trackID: String
    var roleID: String
    var rankIndex: Int = 0
    var yearsInRank: Int = 0
    var yearsInCareer: Int = 0
    var performance: Int = 50
    var medals: Int = 0
    var workedHardThisYear = false
    var triedPromotionThisYear = false

    var track: CareerTrack? { CareerData.byID[trackID] }
    var rank: CareerRank? { track.flatMap { $0.ranks.indices.contains(rankIndex) ? $0.ranks[rankIndex] : nil } }
    var role: CareerRole? { track?.role(roleID) }
    var nextRank: CareerRank? { track.flatMap { $0.ranks.indices.contains(rankIndex + 1) ? $0.ranks[rankIndex + 1] : nil } }
}
