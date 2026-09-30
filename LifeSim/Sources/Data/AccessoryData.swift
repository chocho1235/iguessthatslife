import SwiftUI

enum AccessoryData {
    static let all: [Accessory] = [
        Accessory(id: "cap", name: "Baseball Cap", slot: .head, price: 30, color: .red),
        Accessory(id: "tophat", name: "Top Hat", slot: .head, price: 60, color: .black),
        Accessory(id: "beanie", name: "Beanie", slot: .head, price: 20, color: .blue),

        Accessory(id: "sunglasses", name: "Sunglasses", slot: .face, price: 25, color: .black, isCorrective: true),
        Accessory(id: "roundglasses", name: "Round Glasses", slot: .face, price: 15, color: .orange, isCorrective: true),
        Accessory(id: "eyepatch", name: "Eye Patch", slot: .face, price: 40, color: .black),
        Accessory(id: "readingglasses", name: "Reading Glasses", slot: .face, price: 20, color: .blue, isCorrective: true),
        Accessory(id: "squareglasses", name: "Square Glasses", slot: .face, price: 22, color: .black, isCorrective: true),
        Accessory(id: "cateyeglasses", name: "Cat-Eye Glasses", slot: .face, price: 28, color: .pink, isCorrective: true),
        Accessory(id: "aviators", name: "Aviator Glasses", slot: .face, price: 32, color: .yellow, isCorrective: true),

        Accessory(id: "necklace", name: "Necklace", slot: .neck, price: 35, color: .yellow),
        Accessory(id: "bowtie", name: "Bow Tie", slot: .neck, price: 20, color: .red),
        Accessory(id: "scarf", name: "Scarf", slot: .neck, price: 25, color: .purple),
    ]

    static let byID: [String: Accessory] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

    static func items(for slot: AccessorySlot) -> [Accessory] {
        all.filter { $0.slot == slot }
    }
}
