import SwiftUI

struct BankHubView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    var character: Character { viewModel.character! }

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    SavingsView(viewModel: viewModel)
                } label: {
                    bankRow(icon: "building.columns.fill", color: .mint, title: "Savings", subtitle: "Deposit cash and earn yearly interest")
                }
                NavigationLink {
                    InvestmentsView(viewModel: viewModel)
                } label: {
                    bankRow(icon: "chart.line.uptrend.xyaxis", color: .green, title: "Investments", subtitle: "Buy and sell stocks")
                }
                NavigationLink {
                    CasinoIntroView(viewModel: viewModel)
                } label: {
                    bankRow(icon: "die.face.5.fill", color: .purple, title: "Casino", subtitle: "Try your luck — 18+")
                }
            }
            .navigationTitle("Bank")
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

    private func bankRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
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
    return BankHubView(viewModel: vm)
}
