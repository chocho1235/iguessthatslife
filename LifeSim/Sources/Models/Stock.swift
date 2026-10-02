import Foundation

struct Stock: Identifiable, Hashable {
    let id: String
    let name: String
    let symbol: String
    let basePrice: Double
    /// How much the price can swing in a single year, as a fraction of its
    /// current price. Higher volatility means bigger possible gains and losses.
    let volatility: Double
}
