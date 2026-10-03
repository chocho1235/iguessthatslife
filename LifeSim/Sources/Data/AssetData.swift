import Foundation

enum AssetData {
    static let all: [Asset] = [
        // Cars
        Asset(id: "used_hatchback", name: "Used Hatchback", kind: .car, price: 4_500, yearlyUpkeep: 900, yearlyValueChange: -0.10, happiness: 1),
        Asset(id: "family_sedan", name: "Family Sedan", kind: .car, price: 24_000, yearlyUpkeep: 1_500, yearlyValueChange: -0.12, happiness: 2),
        Asset(id: "pickup_truck", name: "Pickup Truck", kind: .car, price: 38_000, yearlyUpkeep: 2_200, yearlyValueChange: -0.10, happiness: 2),
        Asset(id: "electric_sedan", name: "Electric Sedan", kind: .car, price: 52_000, yearlyUpkeep: 1_200, yearlyValueChange: -0.13, happiness: 3),
        Asset(id: "sports_coupe", name: "Sports Coupe", kind: .car, price: 95_000, yearlyUpkeep: 4_000, yearlyValueChange: -0.12, happiness: 4),
        Asset(id: "luxury_suv", name: "Luxury SUV", kind: .car, price: 120_000, yearlyUpkeep: 5_000, yearlyValueChange: -0.14, happiness: 4),
        Asset(id: "supercar", name: "Supercar", kind: .car, price: 320_000, yearlyUpkeep: 12_000, yearlyValueChange: -0.08, happiness: 6),
        Asset(id: "hypercar", name: "Hypercar", kind: .car, price: 2_800_000, yearlyUpkeep: 60_000, yearlyValueChange: 0.02, happiness: 8),

        // Motorcycles
        Asset(id: "scooter", name: "Scooter", kind: .motorcycle, price: 2_200, yearlyUpkeep: 300, yearlyValueChange: -0.12, happiness: 1),
        Asset(id: "dirt_bike", name: "Dirt Bike", kind: .motorcycle, price: 6_500, yearlyUpkeep: 600, yearlyValueChange: -0.12, happiness: 2),
        Asset(id: "superbike", name: "Superbike", kind: .motorcycle, price: 28_000, yearlyUpkeep: 1_800, yearlyValueChange: -0.10, happiness: 4),

        // Property
        Asset(id: "studio_apartment", name: "Studio Apartment", kind: .house, price: 160_000, yearlyUpkeep: 3_000, yearlyValueChange: 0.03, happiness: 2),
        Asset(id: "lake_cabin", name: "Lake Cabin", kind: .house, price: 280_000, yearlyUpkeep: 4_000, yearlyValueChange: 0.025, happiness: 3),
        Asset(id: "suburban_house", name: "Suburban House", kind: .house, price: 420_000, yearlyUpkeep: 6_000, yearlyValueChange: 0.035, happiness: 4),
        Asset(id: "city_penthouse", name: "City Penthouse", kind: .house, price: 2_400_000, yearlyUpkeep: 40_000, yearlyValueChange: 0.04, happiness: 6),
        Asset(id: "beach_villa", name: "Beach Villa", kind: .house, price: 4_500_000, yearlyUpkeep: 70_000, yearlyValueChange: 0.035, happiness: 7),
        Asset(id: "mansion", name: "Mansion", kind: .house, price: 12_000_000, yearlyUpkeep: 200_000, yearlyValueChange: 0.03, happiness: 8),
        Asset(id: "private_island", name: "Private Island", kind: .house, price: 45_000_000, yearlyUpkeep: 900_000, yearlyValueChange: 0.025, happiness: 10),

        // Boats & yachts
        Asset(id: "fishing_boat", name: "Fishing Boat", kind: .boat, price: 18_000, yearlyUpkeep: 1_500, yearlyValueChange: -0.07, happiness: 2),
        Asset(id: "speedboat", name: "Speedboat", kind: .boat, price: 85_000, yearlyUpkeep: 6_000, yearlyValueChange: -0.08, happiness: 4),
        Asset(id: "sailing_yacht", name: "Sailing Yacht", kind: .boat, price: 650_000, yearlyUpkeep: 50_000, yearlyValueChange: -0.06, happiness: 6),
        Asset(id: "superyacht", name: "Superyacht", kind: .boat, price: 25_000_000, yearlyUpkeep: 2_500_000, yearlyValueChange: -0.05, happiness: 9),

        // Aircraft
        Asset(id: "light_plane", name: "Light Plane", kind: .aircraft, price: 350_000, yearlyUpkeep: 30_000, yearlyValueChange: -0.06, happiness: 5),
        Asset(id: "helicopter", name: "Helicopter", kind: .aircraft, price: 1_800_000, yearlyUpkeep: 150_000, yearlyValueChange: -0.06, happiness: 7),
        Asset(id: "private_jet", name: "Private Jet", kind: .aircraft, price: 40_000_000, yearlyUpkeep: 3_000_000, yearlyValueChange: -0.05, happiness: 10),
    ]

    static let byID: [String: Asset] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

    static func items(for kind: AssetKind) -> [Asset] {
        all.filter { $0.kind == kind }
    }

    /// Down payment needed for a mortgage, as a share of the price.
    static let mortgageDownPayment = 0.2
    static let mortgageInterestRate = 0.045
    /// Yearly payment as a share of the amount borrowed (about 20 years).
    static let mortgagePaymentRate = 0.077
}
