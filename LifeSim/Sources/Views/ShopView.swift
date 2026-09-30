import SwiftUI

struct ShopView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    var character: Character { viewModel.character! }

    var body: some View {
        NavigationStack {
            List {
                ForEach(AccessorySlot.allCases, id: \.self) { slot in
                    Section(slot.rawValue) {
                        ForEach(AccessoryData.items(for: slot)) { item in
                            row(for: item)
                        }
                    }
                }
            }
            .navigationTitle("Shop")
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
    private func row(for item: Accessory) -> some View {
        let owned = character.ownedAccessoryIDs.contains(item.id)
        let equipped = character.equippedAccessoryIDs[item.slot] == item.id

        HStack(spacing: 14) {
            AvatarView(seed: "preview", gender: .male, stage: .adult, equipped: [item])
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
                    if equipped {
                        viewModel.unequip(slot: item.slot)
                    } else {
                        viewModel.equip(item)
                    }
                }
                .buttonStyle(.bordered)
                .tint(equipped ? .green : .blue)
            } else {
                Button("Buy") {
                    viewModel.purchase(item)
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
    return ShopView(viewModel: vm)
}
