import SwiftUI

struct ShopHubView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    var character: Character { viewModel.character! }

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    ShopView(viewModel: viewModel)
                } label: {
                    shopRow(icon: "sunglasses.fill", color: .orange, title: "Accessories", subtitle: "Hats, glasses, and jewelry")
                }
                NavigationLink {
                    ClothingShopView(viewModel: viewModel)
                } label: {
                    shopRow(icon: "tshirt.fill", color: .purple, title: "Clothing", subtitle: "Shirts, hoodies, suits, and more")
                }
                NavigationLink {
                    AssetShopView(viewModel: viewModel)
                } label: {
                    shopRow(icon: "house.fill", color: .teal, title: "Assets", subtitle: "Cars, houses, yachts — they cost upkeep every year")
                }
                NavigationLink {
                    WeaponShopView(viewModel: viewModel)
                } label: {
                    shopRow(icon: "shield.lefthalf.filled", color: .red, title: "Weapons", subtitle: "Self-defense gear — some are illegal")
                }
            }
            .navigationTitle("Shops")
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

    private func shopRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(color.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.bold())
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let vm = GameViewModel()
    vm.startNewLife()
    return ShopHubView(viewModel: vm)
}
