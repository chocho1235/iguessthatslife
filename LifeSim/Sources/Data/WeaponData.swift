import Foundation

enum WeaponData {
    static let all: [Weapon] = [
        // Legal self-defense / sporting goods
        Weapon(id: "baseball_bat", name: "Baseball Bat", category: "Sporting Goods", price: 45, isIllegal: false),
        Weapon(id: "pepper_spray", name: "Pepper Spray", category: "Self-Defense", price: 25, isIllegal: false),
        Weapon(id: "taser", name: "Taser", category: "Self-Defense", price: 90, isIllegal: false),
        Weapon(id: "hunting_knife", name: "Hunting Knife", category: "Outdoors", price: 60, isIllegal: false),
        Weapon(id: "pocket_knife", name: "Pocket Knife", category: "Outdoors", price: 35, isIllegal: false),
        Weapon(id: "crossbow", name: "Crossbow", category: "Sporting Goods", price: 220, isIllegal: false),
        Weapon(id: "hunting_rifle", name: "Hunting Rifle", category: "Sporting Goods", price: 480, isIllegal: false),

        // Illegal — buying these is itself a crime
        Weapon(id: "switchblade", name: "Switchblade", category: "Banned Blade", price: 80, isIllegal: true),
        Weapon(id: "brass_knuckles", name: "Brass Knuckles", category: "Banned Weapon", price: 50, isIllegal: true),
        Weapon(id: "handgun", name: "Handgun", category: "Unlicensed Firearm", price: 420, isIllegal: true),
        Weapon(id: "sawed_off_shotgun", name: "Sawed-Off Shotgun", category: "Unlicensed Firearm", price: 650, isIllegal: true),
        Weapon(id: "assault_rifle", name: "Assault Rifle", category: "Unlicensed Firearm", price: 1400, isIllegal: true),
        Weapon(id: "machete", name: "Machete", category: "Banned Blade", price: 110, isIllegal: true),
        Weapon(id: "stun_baton", name: "Illegal Stun Baton", category: "Banned Weapon", price: 150, isIllegal: true),
        Weapon(id: "silencer_pistol", name: "Silenced Pistol", category: "Unlicensed Firearm", price: 900, isIllegal: true),
    ]

    static let byID: [String: Weapon] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

    static func items(for category: String) -> [Weapon] {
        all.filter { $0.category == category }
    }

    static var categories: [String] {
        var seen: [String] = []
        for weapon in all where !seen.contains(weapon.category) {
            seen.append(weapon.category)
        }
        return seen
    }
}
