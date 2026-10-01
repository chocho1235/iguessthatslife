import SwiftUI

struct ClothingShopView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    var character: Character { viewModel.character! }

    var body: some View {
        NavigationStack {
            List {
                ForEach(OutfitStyle.allCases, id: \.self) { style in
                    let items = OutfitData.items(for: style)
                    if !items.isEmpty {
                        Section(style.rawValue) {
                            ForEach(items) { item in
                                row(for: item)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Clothing")
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
    private func row(for item: Outfit) -> some View {
        let owned = character.ownedOutfitIDs.contains(item.id)
        let equipped = character.equippedOutfitID == item.id

        HStack(spacing: 14) {
            AvatarView(seed: "preview", gender: .male, stage: .adult, equippedOutfit: item)
                .frame(width: 54, height: 54)
                .background(Color(.tertiarySystemBackground))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name).font(.subheadline.bold())
                if !owned {
                    Text("$\(item.price)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if owned {
                Button(equipped ? "Equipped" : "Equip") {
                    viewModel.equipOutfit(item)
                }
                .buttonStyle(.bordered)
                .tint(equipped ? .green : .blue)
                .disabled(equipped)
            } else {
                Button("Buy") {
                    viewModel.purchaseOutfit(item)
                }
                .buttonStyle(.borderedProminent)
                .disabled(character.cash < item.price)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let vm = GameViewModel()
    vm.startNewLife()
    return ClothingShopView(viewModel: vm)
}
