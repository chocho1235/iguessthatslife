import SwiftUI

struct WeaponShopView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var feedback: String?

    var character: Character { viewModel.character! }

    var body: some View {
        NavigationStack {
            List {
                if let feedback {
                    Section {
                        Text(feedback)
                            .font(.subheadline.bold())
                            .foregroundStyle(.blue)
                    }
                }

                if let ownedName = character.weaponName {
                    Section("Owned") {
                        let owned = WeaponData.all.first { $0.name == ownedName }
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(ownedName).font(.subheadline.bold())
                                if let owned {
                                    Text("Sell for $\(owned.sellValue)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Button("Sell") {
                                withAnimation { feedback = viewModel.sellWeapon() }
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        }
                    }
                }

                ForEach(WeaponData.categories, id: \.self) { category in
                    Section(category) {
                        ForEach(WeaponData.items(for: category)) { weapon in
                            row(for: weapon)
                        }
                    }
                }
            }
            .navigationTitle("Weapons")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("💰 $\(character.cash)")
                        .font(.headline)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func row(for weapon: Weapon) -> some View {
        HStack(spacing: 14) {
            Image(systemName: weapon.isIllegal ? "exclamationmark.triangle.fill" : "shield.fill")
                .font(.title2)
                .foregroundStyle(weapon.isIllegal ? .red : .blue)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(weapon.name).font(.subheadline.bold())
                    if weapon.isIllegal {
                        Text("ILLEGAL")
                            .font(.caption2.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
                Text(weapon.isIllegal ? "Buying this is a crime — adds to your record." : "$\(weapon.price)")
                    .font(.caption2)
                    .foregroundStyle(weapon.isIllegal ? .red : .secondary)
            }

            Spacer()

            Button("Buy $\(weapon.price)") {
                withAnimation { feedback = viewModel.purchaseWeapon(weapon) }
            }
            .buttonStyle(.borderedProminent)
            .tint(weapon.isIllegal ? .red : .blue)
            .disabled(character.cash < weapon.price || character.weaponName != nil)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let vm = GameViewModel()
    vm.startNewLife()
    return WeaponShopView(viewModel: vm)
}
