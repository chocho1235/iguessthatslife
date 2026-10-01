import Foundation

struct LegalTrouble: Identifiable {
    let id = UUID()
    let chargeDescription: String
    let bailCost: Int
    let lawyerCost: Int
    let confiscatesWeaponWithoutLawyer: Bool
    /// If convicted without a lawyer, how many years get served.
    let jailYearsIfConvicted: Int
    /// Chance of conviction when going without a lawyer. A lawyer always
    /// beats the charge down to a fine — that's what the huge fee buys.
    let convictionChanceWithoutLawyer: Double
}
