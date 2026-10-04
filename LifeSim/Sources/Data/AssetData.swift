import Foundation

enum AssetData {
    static let all: [Asset] = [
        Asset(id: "bicycle", name: "Bicycle", category: .vehicle, price: 300, yearlyUpkeep: 20, happinessBonus: 1, icon: "bicycle"),
        Asset(id: "used_hatchback", name: "Used Hatchback", category: .vehicle, price: 6_000, yearlyUpkeep: 900, happinessBonus: 2, icon: "car.fill"),
        Asset(id: "family_sedan", name: "Family Sedan", category: .vehicle, price: 22_000, yearlyUpkeep: 1_800, happinessBonus: 3, icon: "car.side.fill"),
        Asset(id: "sports_car", name: "Sports Car", category: .vehicle, price: 85_000, yearlyUpkeep: 5_000, happinessBonus: 6, icon: "car.side.fill"),
        Asset(id: "supercar", name: "Supercar", category: .vehicle, price: 350_000, yearlyUpkeep: 15_000, happinessBonus: 10, icon: "car.fill"),

        Asset(id: "studio_flat", name: "Studio Flat", category: .property, price: 90_000, yearlyUpkeep: 4_000, happinessBonus: 3, icon: "building.fill"),
        Asset(id: "suburban_house", name: "Suburban House", category: .property, price: 250_000, yearlyUpkeep: 9_000, happinessBonus: 6, icon: "house.fill"),
        Asset(id: "lake_cabin", name: "Lake Cabin", category: .property, price: 400_000, yearlyUpkeep: 12_000, happinessBonus: 8, icon: "tent.fill"),
        Asset(id: "villa", name: "Seaside Villa", category: .property, price: 1_500_000, yearlyUpkeep: 40_000, happinessBonus: 12, icon: "house.lodge.fill"),
        Asset(id: "penthouse", name: "City Penthouse", category: .property, price: 3_000_000, yearlyUpkeep: 70_000, happinessBonus: 15, icon: "building.2.fill"),

        Asset(id: "jet_ski", name: "Jet Ski", category: .luxury, price: 12_000, yearlyUpkeep: 1_200, happinessBonus: 3, icon: "water.waves"),
        Asset(id: "private_jet", name: "Private Jet Share", category: .luxury, price: 1_200_000, yearlyUpkeep: 120_000, happinessBonus: 14, icon: "airplane"),
        Asset(id: "yacht", name: "Yacht", category: .luxury, price: 2_500_000, yearlyUpkeep: 180_000, happinessBonus: 18, icon: "ferry.fill"),
        Asset(id: "superyacht", name: "Superyacht", category: .luxury, price: 40_000_000, yearlyUpkeep: 2_000_000, happinessBonus: 25, icon: "ferry.fill"),
    ]

    static let byID: [String: Asset] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
}
