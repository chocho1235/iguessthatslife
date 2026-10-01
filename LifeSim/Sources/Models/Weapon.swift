import Foundation

struct Weapon: Identifiable, Hashable {
    let id: String
    let name: String
    let category: String
    let price: Int
    /// Owning this weapon is itself a crime — buying it adds to your
    /// criminal record and the shop makes that explicit before you buy.
    let isIllegal: Bool

    var sellValue: Int { Int(Double(price) * 0.5) }
}
