import Foundation

struct LegalTrouble: Identifiable {
    let id = UUID()
    let chargeDescription: String
    let bailCost: Int
    let lawyerCost: Int
    let confiscatesWeaponWithoutLawyer: Bool
}
