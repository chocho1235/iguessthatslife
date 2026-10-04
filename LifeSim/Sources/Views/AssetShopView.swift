import SwiftUI

struct AssetShopView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var feedback: String?

    var character: Character { viewModel.character! }

    var body: some View {
        NavigationStack {
            List {
                if let feedback {
                    Section {
                        Text(feedback).font(.subheadline.bold()).foregroundStyle(.blue)
                    }
                }
                ForEach(AssetCategory.allCases, id: \.self) { category in
                    Section(category.rawValue) {
                        ForEach(AssetData.all.filter { $0.category == category }) { asset in
                            row(for: asset)
                        }
                    }
                }
            }
            .navigationTitle("Assets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("💰 $\(character.cash)").font(.headline)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func row(for asset: Asset) -> some View {
        let owned = character.ownedAssetIDs.contains(asset.id)
        HStack(spacing: 14) {
            Image(systemName: asset.icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(asset.name).font(.subheadline.bold())
                Text("$\(asset.price) · upkeep $\(asset.yearlyUpkeep)/yr · +\(asset.happinessBonus) happiness/yr")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if owned {
                Button("Sell $\(asset.sellValue)") {
                    withAnimation { feedback = viewModel.sellAsset(asset) }
                }
                .buttonStyle(.bordered)
                .tint(.red)
            } else {
                Button("Buy") {
                    withAnimation { feedback = viewModel.buyAsset(asset) }
                }
                .buttonStyle(.borderedProminent)
                .disabled(character.cash < asset.price)
            }
        }
        .padding(.vertical, 4)
    }
}
