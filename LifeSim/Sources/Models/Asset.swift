import SwiftUI

enum AssetKind: String, CaseIterable {
    case car
    case motorcycle
    case house
    case boat
    case aircraft

    var title: String {
        switch self {
        case .car: return "Cars"
        case .motorcycle: return "Motorcycles"
        case .house: return "Property"
        case .boat: return "Boats & Yachts"
        case .aircraft: return "Aircraft"
        }
    }

    var icon: String {
        switch self {
        case .car: return "car.fill"
        case .motorcycle: return "scooter"
        case .house: return "house.fill"
        case .boat: return "sailboat.fill"
        case .aircraft: return "airplane"
        }
    }

    var color: Color {
        switch self {
        case .car: return .blue
        case .motorcycle: return .orange
        case .house: return .green
        case .boat: return .teal
        case .aircraft: return .indigo
        }
    }

    var minimumAge: Int {
        switch self {
        case .car, .motorcycle: return 16
        case .house, .boat: return 18
        case .aircraft: return 21
        }
    }

    /// Only property can be bought with a mortgage.
    var allowsMortgage: Bool { self == .house }

    /// Cars and motorcycles double as a getaway vehicle after a crime.
    var isGetawayVehicle: Bool { self == .car || self == .motorcycle }
}

/// Something in the dealership or on the property market. Prices are in
/// US-pegged dollars and get scaled to the local economy when bought.
struct Asset: Identifiable, Hashable {
    let id: String
    let name: String
    let kind: AssetKind
    let price: Int
    /// Insurance, fuel, taxes, crew — whatever it costs to keep each year.
    let yearlyUpkeep: Int
    /// Average yearly change in value: negative for things that lose value
    /// like cars, positive for property.
    let yearlyValueChange: Double
    /// Added to happiness every year you own it.
    let happiness: Int
}

/// An asset the character actually owns. Money values are stored in local
/// dollars at the time of purchase.
struct OwnedAsset: Codable, Identifiable, Hashable {
    var id = UUID()
    let assetID: String
    let purchasePrice: Int
    var value: Int
    let upkeep: Int
    /// Mortgage still owed. Zero if it was bought outright.
    var loanRemaining: Int = 0
    var yearlyPayment: Int = 0
    var yearsOwned: Int = 0

    var asset: Asset? { AssetData.byID[assetID] }
    /// What selling it would actually put in your pocket.
    var equity: Int { value - loanRemaining }
}
