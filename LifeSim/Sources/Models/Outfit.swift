import SwiftUI

enum OutfitStyle: String, CaseIterable {
    case tshirt = "T-Shirt"
    case tank = "Tank Top"
    case hoodie = "Hoodie"
    case jacket = "Jacket"
    case suit = "Suit"
    case dress = "Dress"
}

struct Outfit: Identifiable, Hashable {
    let id: String
    let name: String
    let style: OutfitStyle
    let price: Int
    let color: Color
}
