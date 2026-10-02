import Foundation

enum StockData {
    static let all: [Stock] = [
        Stock(id: "northstar_bank", name: "NorthStar Bank", symbol: "NSB", basePrice: 90, volatility: 0.08),
        Stock(id: "megamart", name: "MegaMart", symbol: "MMT", basePrice: 60, volatility: 0.10),
        Stock(id: "fructa", name: "Fructa Inc.", symbol: "FRCT", basePrice: 150, volatility: 0.18),
        Stock(id: "voltrix", name: "Voltrix Energy", symbol: "VLTX", basePrice: 35, volatility: 0.22),
        Stock(id: "cryptara", name: "Cryptara Coin", symbol: "CRYT", basePrice: 12, volatility: 0.45),
    ]

    static let byID: [String: Stock] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

    static func startingPrices() -> [String: Double] {
        Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0.basePrice) })
    }
}
