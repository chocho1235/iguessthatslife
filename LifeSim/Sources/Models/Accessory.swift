import SwiftUI

enum AccessorySlot: String, CaseIterable, Hashable, Codable {
    case head = "Head"
    case face = "Face"
    case neck = "Neck"
    case ears = "Ears"
    case wrist = "Wrist"
}

struct Accessory: Identifiable, Hashable {
    let id: String
    let name: String
    let slot: AccessorySlot
    let price: Int
    let color: Color
    /// Corrective glasses clear blurry vision from Poor Vision; sunglasses,
    /// an eye patch, and other face accessories don't.
    let isCorrective: Bool
    /// Worn like clothing (a balaclava), so it's sold in the Clothing shop
    /// instead of with the accessories.
    let isClothing: Bool

    init(id: String, name: String, slot: AccessorySlot, price: Int, color: Color, isCorrective: Bool = false, isClothing: Bool = false) {
        self.id = id
        self.name = name
        self.slot = slot
        self.price = price
        self.color = color
        self.isCorrective = isCorrective
        self.isClothing = isClothing
    }
}
