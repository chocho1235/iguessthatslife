import SwiftUI

struct AssetsView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var feedback: String?
    @State private var pendingSale: OwnedAsset?

    var character: Character { viewModel.character! }

    private var totalValue: Int { character.ownedAssets.reduce(0) { $0 + $1.value } }
    private var totalDebt: Int { character.ownedAssets.reduce(0) { $0 + $1.loanRemaining } }
    private var totalUpkeep: Int { character.ownedAssets.reduce(0) { $0 + $1.upkeep + $1.yearlyPayment * ($1.loanRemaining > 0 ? 1 : 0) } }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 10) {
                        summaryTile("Net Worth", value: viewModel.netWorth, color: .green)
                        summaryTile("Your Stuff", value: totalValue, color: .blue)
                        summaryTile("Debt", value: totalDebt, color: totalDebt > 0 ? .red : .secondary)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                    if totalUpkeep > 0 {
                        Text("Running costs: $\(totalUpkeep) a year, paid from cash first and then savings. Miss a payment and it gets taken away.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if let feedback {
                    Section {
                        Text(feedback)
                            .font(.subheadline.bold())
                            .foregroundStyle(.blue)
                    }
                }

                if !character.ownedAssets.isEmpty {
                    Section("You Own") {
                        ForEach(character.ownedAssets) { owned in
                            ownedRow(owned)
                        }
                    }
                }

                ForEach(AssetKind.allCases, id: \.self) { kind in
                    Section {
                        ForEach(AssetData.items(for: kind)) { asset in
                            shopRow(asset)
                        }
                    } header: {
                        Label(kind.title, systemImage: kind.icon)
                    } footer: {
                        Text(footer(for: kind))
                    }
                }
            }
            .navigationTitle("Assets")
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
            .confirmationDialog(
                "Sell your \(pendingSale?.asset?.name ?? "asset")?",
                isPresented: Binding(get: { pendingSale != nil }, set: { if !$0 { pendingSale = nil } }),
                titleVisibility: .visible,
                presenting: pendingSale
            ) { owned in
                Button(owned.equity >= 0 ? "Sell for $\(owned.equity)" : "Sell and pay $\(-owned.equity)", role: .destructive) {
                    withAnimation { feedback = viewModel.sellAsset(owned.id) }
                }
            } message: { owned in
                Text(owned.loanRemaining > 0
                     ? "It's worth $\(owned.value), but you still owe $\(owned.loanRemaining) on the mortgage."
                     : "It's worth $\(owned.value) right now. You paid $\(owned.purchasePrice).")
            }
        }
    }

    private func footer(for kind: AssetKind) -> String {
        switch kind {
        case .car: return "Age 16+. Cars lose value every year, but double as a getaway car."
        case .motorcycle: return "Age 16+. Cheap and fun, but crashes are more common."
        case .house: return "Age 18+. Property usually goes up in value. Get a mortgage with 20% down if you have a full-time job."
        case .boat: return "Age 18+. Boats cost a lot to keep running."
        case .aircraft: return "Age 21+. The ultimate flex, with running costs to match."
        }
    }

    private func summaryTile(_ title: String, value: Int, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
            Text("$\(value)")
                .font(.subheadline.bold())
                .monospacedDigit()
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(color.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func icon(for kind: AssetKind) -> some View {
        Image(systemName: kind.icon)
            .font(.title3)
            .foregroundStyle(.white)
            .frame(width: 40, height: 40)
            .background(kind.color.gradient)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private func ownedRow(_ owned: OwnedAsset) -> some View {
        if let asset = owned.asset {
            let change = owned.purchasePrice > 0 ? Double(owned.value - owned.purchasePrice) / Double(owned.purchasePrice) : 0
            HStack(spacing: 12) {
                icon(for: asset.kind)
                VStack(alignment: .leading, spacing: 2) {
                    Text(asset.name).font(.subheadline.bold())
                    HStack(spacing: 4) {
                        Text("Worth $\(owned.value)")
                        Text("(\(change >= 0 ? "+" : "")\(Int((change * 100).rounded()))%)")
                            .foregroundStyle(change >= 0 ? .green : .red)
                    }
                    .font(.caption)
                    Text(owned.loanRemaining > 0
                         ? "Owes $\(owned.loanRemaining) · $\(owned.yearlyPayment + owned.upkeep)/yr"
                         : "Upkeep $\(owned.upkeep)/yr · \(owned.yearsOwned) yr\(owned.yearsOwned == 1 ? "" : "s") owned")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Sell") { pendingSale = owned }
                    .buttonStyle(.bordered)
                    .tint(.red)
            }
            .padding(.vertical, 2)
        }
    }

    @ViewBuilder
    private func shopRow(_ asset: Asset) -> some View {
        let price = viewModel.localPrice(of: asset)
        let owned = character.ownedAssets.contains { $0.assetID == asset.id }
        let cashBlocker = viewModel.assetPurchaseBlocker(asset, mortgage: false)
        let mortgageBlocker = asset.kind.allowsMortgage ? viewModel.assetPurchaseBlocker(asset, mortgage: true) : "n/a"

        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                icon(for: asset.kind)
                VStack(alignment: .leading, spacing: 2) {
                    Text(asset.name).font(.subheadline.bold())
                    Text("$\(price)")
                        .font(.caption.bold())
                        .monospacedDigit()
                    Text("Upkeep $\(viewModel.localUpkeep(of: asset))/yr · +\(asset.happiness) happiness · \(asset.yearlyValueChange >= 0 ? "gains" : "loses") ~\(Int(abs(asset.yearlyValueChange) * 100))%/yr")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                if owned {
                    Text("Owned")
                        .font(.caption.bold())
                        .foregroundStyle(.green)
                } else {
                    Button("Buy") {
                        withAnimation { feedback = viewModel.buyAsset(asset) }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(asset.kind.color)
                    .disabled(cashBlocker != nil)
                }
            }
            if !owned, asset.kind.allowsMortgage {
                Button {
                    withAnimation { feedback = viewModel.buyAsset(asset, mortgage: true) }
                } label: {
                    Text(mortgageBlocker == nil
                         ? "Mortgage it: $\(viewModel.mortgageDownPayment(for: asset)) down"
                         : "Mortgage: \(mortgageBlocker ?? "")")
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)
                .disabled(mortgageBlocker != nil)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let vm = GameViewModel()
    vm.startNewLife()
    return AssetsView(viewModel: vm)
}
