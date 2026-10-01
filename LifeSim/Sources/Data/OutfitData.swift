import SwiftUI

enum OutfitData {
    static let all: [Outfit] = [
        Outfit(id: "basic_tee", name: "Basic Tee", style: .tshirt, price: 0, color: Color(red: 0.55, green: 0.58, blue: 0.62)),

        Outfit(id: "tee_red", name: "Red Tee", style: .tshirt, price: 18, color: .red),
        Outfit(id: "tee_blue", name: "Blue Tee", style: .tshirt, price: 18, color: .blue),
        Outfit(id: "tee_green", name: "Green Tee", style: .tshirt, price: 18, color: .green),

        Outfit(id: "tank_white", name: "White Tank", style: .tank, price: 16, color: .white),
        Outfit(id: "tank_black", name: "Black Tank", style: .tank, price: 16, color: .black),

        Outfit(id: "hoodie_gray", name: "Gray Hoodie", style: .hoodie, price: 45, color: Color(white: 0.5)),
        Outfit(id: "hoodie_navy", name: "Navy Hoodie", style: .hoodie, price: 45, color: Color(red: 0.15, green: 0.2, blue: 0.4)),
        Outfit(id: "hoodie_maroon", name: "Maroon Hoodie", style: .hoodie, price: 48, color: Color(red: 0.45, green: 0.12, blue: 0.18)),

        Outfit(id: "jacket_denim", name: "Denim Jacket", style: .jacket, price: 65, color: Color(red: 0.30, green: 0.45, blue: 0.65)),
        Outfit(id: "jacket_leather", name: "Leather Jacket", style: .jacket, price: 90, color: Color(red: 0.18, green: 0.14, blue: 0.12)),
        Outfit(id: "jacket_bomber", name: "Bomber Jacket", style: .jacket, price: 75, color: Color(red: 0.25, green: 0.35, blue: 0.22)),

        Outfit(id: "suit_black", name: "Black Suit", style: .suit, price: 140, color: .black),
        Outfit(id: "suit_navy", name: "Navy Suit", style: .suit, price: 150, color: Color(red: 0.12, green: 0.16, blue: 0.32)),
        Outfit(id: "suit_gray", name: "Gray Suit", style: .suit, price: 130, color: Color(white: 0.35)),

        Outfit(id: "dress_red", name: "Red Dress", style: .dress, price: 85, color: Color(red: 0.75, green: 0.12, blue: 0.22)),
        Outfit(id: "dress_black", name: "Black Dress", style: .dress, price: 90, color: .black),
        Outfit(id: "dress_gold", name: "Gold Dress", style: .dress, price: 110, color: Color(red: 0.85, green: 0.68, blue: 0.25)),
    ]

    static let byID: [String: Outfit] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

    static func items(for style: OutfitStyle) -> [Outfit] {
        all.filter { $0.style == style && $0.id != "basic_tee" }
    }
}
