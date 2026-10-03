import Foundation

enum WeaponData {
    static let all: [Weapon] = [
        // Legal self-defense / sporting goods
        Weapon(id: "pepper_spray", name: "Pepper Spray", category: "Self-Defense", price: 25, isIllegal: false, power: 2),
        Weapon(id: "taser", name: "Taser", category: "Self-Defense", price: 90, isIllegal: false, power: 3),
        Weapon(id: "baseball_bat", name: "Baseball Bat", category: "Sporting Goods", price: 45, isIllegal: false, power: 3),
        Weapon(id: "hockey_stick", name: "Hockey Stick", category: "Sporting Goods", price: 40, isIllegal: false, power: 2),
        Weapon(id: "golf_club", name: "Golf Club", category: "Sporting Goods", price: 120, isIllegal: false, power: 3),
        Weapon(id: "crossbow", name: "Crossbow", category: "Sporting Goods", price: 220, isIllegal: false, power: 5),
        Weapon(id: "compound_bow", name: "Compound Bow", category: "Sporting Goods", price: 340, isIllegal: false, power: 5),
        Weapon(id: "hunting_rifle", name: "Hunting Rifle", category: "Sporting Goods", price: 480, isIllegal: false, power: 7, isFirearm: true),
        Weapon(id: "pump_shotgun", name: "Pump Shotgun", category: "Sporting Goods", price: 560, isIllegal: false, power: 7, isFirearm: true),
        Weapon(id: "pocket_knife", name: "Pocket Knife", category: "Outdoors", price: 35, isIllegal: false, power: 2),
        Weapon(id: "hunting_knife", name: "Hunting Knife", category: "Outdoors", price: 60, isIllegal: false, power: 4),
        Weapon(id: "crowbar", name: "Crowbar", category: "Hardware", price: 30, isIllegal: false, power: 3),
        Weapon(id: "sledgehammer", name: "Sledgehammer", category: "Hardware", price: 55, isIllegal: false, power: 4),
        Weapon(id: "fire_axe", name: "Fire Axe", category: "Hardware", price: 75, isIllegal: false, power: 5),

        // Illegal — only a crime if the police catch you with it
        Weapon(id: "switchblade", name: "Switchblade", category: "Banned Blade", price: 80, isIllegal: true, power: 3),
        Weapon(id: "butterfly_knife", name: "Butterfly Knife", category: "Banned Blade", price: 95, isIllegal: true, power: 3),
        Weapon(id: "machete", name: "Machete", category: "Banned Blade", price: 110, isIllegal: true, power: 5),
        Weapon(id: "katana", name: "Katana", category: "Banned Blade", price: 650, isIllegal: true, power: 6),
        Weapon(id: "brass_knuckles", name: "Brass Knuckles", category: "Banned Weapon", price: 50, isIllegal: true, power: 2),
        Weapon(id: "throwing_stars", name: "Throwing Stars", category: "Banned Weapon", price: 45, isIllegal: true, power: 2),
        Weapon(id: "nunchucks", name: "Nunchucks", category: "Banned Weapon", price: 60, isIllegal: true, power: 3),
        Weapon(id: "stun_baton", name: "Illegal Stun Baton", category: "Banned Weapon", price: 150, isIllegal: true, power: 4),
        Weapon(id: "handgun", name: "Handgun", category: "Unlicensed Firearm", price: 420, isIllegal: true, power: 7, isFirearm: true),
        Weapon(id: "revolver", name: "Revolver", category: "Unlicensed Firearm", price: 500, isIllegal: true, power: 7, isFirearm: true),
        Weapon(id: "sawed_off_shotgun", name: "Sawed-Off Shotgun", category: "Unlicensed Firearm", price: 650, isIllegal: true, power: 8, isFirearm: true),
        Weapon(id: "silencer_pistol", name: "Silenced Pistol", category: "Unlicensed Firearm", price: 900, isIllegal: true, power: 8, isFirearm: true),
        Weapon(id: "smg", name: "Submachine Gun", category: "Unlicensed Firearm", price: 1_200, isIllegal: true, power: 9, isFirearm: true),
        Weapon(id: "assault_rifle", name: "Assault Rifle", category: "Unlicensed Firearm", price: 1_400, isIllegal: true, power: 10, isFirearm: true),
        Weapon(id: "sniper_rifle", name: "Sniper Rifle", category: "Unlicensed Firearm", price: 2_200, isIllegal: true, power: 9, isFirearm: true),
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
