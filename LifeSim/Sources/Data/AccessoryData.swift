import SwiftUI

enum AccessoryData {
    static let all: [Accessory] = [
        Accessory(id: "cap", name: "Baseball Cap", slot: .head, price: 30, color: .red),
        Accessory(id: "tophat", name: "Top Hat", slot: .head, price: 60, color: .black),
        Accessory(id: "beanie", name: "Beanie", slot: .head, price: 20, color: .blue),
        Accessory(id: "headband", name: "Headband", slot: .head, price: 15, color: .pink),
        Accessory(id: "flowercrown", name: "Flower Crown", slot: .head, price: 28, color: .white),
        Accessory(id: "bandana", name: "Bandana", slot: .head, price: 18, color: .orange),

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
        Accessory(id: "tie", name: "Necktie", slot: .neck, price: 30, color: .red),
        Accessory(id: "tie_striped", name: "Striped Tie", slot: .neck, price: 32, color: .blue),
        Accessory(id: "gold_chain", name: "Gold Chain", slot: .neck, price: 55, color: .yellow),

        Accessory(id: "stud_earrings", name: "Stud Earrings", slot: .ears, price: 22, color: .white),
        Accessory(id: "hoop_earrings", name: "Hoop Earrings", slot: .ears, price: 26, color: .yellow),

        Accessory(id: "watch", name: "Wrist Watch", slot: .wrist, price: 45, color: .black),
        Accessory(id: "bracelet", name: "Bracelet", slot: .wrist, price: 20, color: .yellow),
    ]

    static let byID: [String: Accessory] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

    static func items(for slot: AccessorySlot) -> [Accessory] {
        all.filter { $0.slot == slot }
    }
}
