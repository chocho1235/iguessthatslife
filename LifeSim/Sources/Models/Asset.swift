import Foundation

enum AssetCategory: String, CaseIterable, Codable {
    case vehicle = "Vehicles"
    case property = "Property"
    case luxury = "Luxury"
}

struct Asset: Identifiable, Hashable {
    let id: String
    let name: String
    let category: AssetCategory
    let price: Int
    let yearlyUpkeep: Int
    let happinessBonus: Int
    let icon: String

    var sellValue: Int { Int(Double(price) * 0.6) }
}
