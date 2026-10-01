import SwiftUI

struct LegalTroubleView: View {
    let trouble: LegalTrouble
    let cash: Int
    let onResolve: (Bool) -> Void
    @Environment(\.dismiss) private var dismiss

    private var canAffordLawyer: Bool { cash >= trouble.lawyerCost }

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "building.columns.fill")
                .font(.system(size: 44, weight: .bold))
                .foregroundStyle(.red)
                .padding()
                .background(Color.red.opacity(0.14))
                .clipShape(Circle())

            VStack(spacing: 8) {
                Text("You've Been Arrested")
                    .font(.title2.bold())
                Text("Charge: \(trouble.chargeDescription)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Do you hire an expensive lawyer to fight the charge, or take it as-is?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                Button {
                    onResolve(true)
                    dismiss()
                } label: {
                    VStack(spacing: 2) {
                        Label("Hire a Lawyer", systemImage: "briefcase.fill")
                        Text("$\(trouble.lawyerCost) — minimal record impact")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(.indigo)
                .disabled(!canAffordLawyer)

                Button {
                    onResolve(false)
                    dismiss()
                } label: {
                    VStack(spacing: 2) {
                        Text("Take the Charge")
                        Text("$\(min(cash, trouble.bailCost)) bail · \(Int(trouble.convictionChanceWithoutLawyer * 100))% chance of \(trouble.jailYearsIfConvicted)-year sentence")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }

            if !canAffordLawyer {
                Text("You can't afford a lawyer right now (you have $\(cash)).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(28)
        .interactiveDismissDisabled()
    }
}

#Preview {
    LegalTroubleView(
        trouble: LegalTrouble(chargeDescription: "Armed Robbery", bailCost: 500, lawyerCost: 9000, confiscatesWeaponWithoutLawyer: true, jailYearsIfConvicted: 2, convictionChanceWithoutLawyer: 0.45),
        cash: 12000,
        onResolve: { _ in }
    )
}
