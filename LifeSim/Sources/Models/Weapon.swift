import Foundation

struct Weapon: Identifiable, Hashable {
    let id: String
    let name: String
    let category: String
    let price: Int
    /// Owning this is a crime, but only if the police actually find it on
    /// you. Buying one doesn't touch your record by itself.
    let isIllegal: Bool
    /// 1...10 — how much it helps in a fight or a hold-up.
    let power: Int
    let isFirearm: Bool

    init(id: String, name: String, category: String, price: Int, isIllegal: Bool, power: Int, isFirearm: Bool = false) {
        self.id = id
        self.name = name
        self.category = category
        self.price = price
        self.isIllegal = isIllegal
        self.power = power
        self.isFirearm = isFirearm
    }

    var sellValue: Int { Int(Double(price) * 0.5) }
}
