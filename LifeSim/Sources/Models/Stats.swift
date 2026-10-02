import Foundation

struct Stats: Codable {
    var health: Int
    var happiness: Int
    var smarts: Int
    var looks: Int

    mutating func adjust(health: Int = 0, happiness: Int = 0, smarts: Int = 0, looks: Int = 0) {
        self.health = Self.clamp(self.health + health)
        self.happiness = Self.clamp(self.happiness + happiness)
        self.smarts = Self.clamp(self.smarts + smarts)
        self.looks = Self.clamp(self.looks + looks)
    }

    private static func clamp(_ value: Int) -> Int {
        min(100, max(0, value))
    }

    static func random() -> Stats {
        Stats(
            health: Int.random(in: 55...90),
            happiness: Int.random(in: 55...90),
            smarts: Int.random(in: 40...80),
            looks: Int.random(in: 40...90)
        )
    }
}
