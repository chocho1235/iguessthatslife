import SwiftUI

enum AccessorySlot: String, CaseIterable, Hashable {
    case head = "Head"
    case face = "Face"
    case neck = "Neck"
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

    init(id: String, name: String, slot: AccessorySlot, price: Int, color: Color, isCorrective: Bool = false) {
        self.id = id
        self.name = name
        self.slot = slot
        self.price = price
        self.color = color
        self.isCorrective = isCorrective
    }
}
