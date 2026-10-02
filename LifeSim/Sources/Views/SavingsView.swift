import SwiftUI

struct SavingsView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var amount: Int = 50
    @State private var feedback: String?

    private static let presets = [50, 100, 500, 1000]

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

                Section("Balances") {
                    balanceRow(title: "Cash on hand", value: character.cash, color: .orange)
                    balanceRow(title: "Savings balance", value: character.bankBalance, color: .mint)
                }

                Section {
                    Text("Your savings earn about 4% interest every year you age up, whether you're free, traveling, or locked up.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Amount") {
                    Stepper("Amount: $\(amount)", value: $amount, in: 10...1_000_000, step: 10)
                    HStack {
                        ForEach(Self.presets, id: \.self) { preset in
                            Button("$\(preset)") { amount = preset }
                                .buttonStyle(.bordered)
                        }
                    }
                }

                Section {
                    Button {
                        withAnimation { feedback = viewModel.depositToBank(amount) }
                    } label: {
                        Label("Deposit $\(amount)", systemImage: "arrow.down.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.mint)
                    .disabled(character.cash < amount)

                    Button {
                        withAnimation { feedback = viewModel.withdrawFromBank(amount) }
                    } label: {
                        Label("Withdraw $\(amount)", systemImage: "arrow.up.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)
                    .disabled(character.bankBalance < amount)
                }
            }
            .navigationTitle("Savings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func balanceRow(title: String, value: Int, color: Color) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text("$\(value)")
                .font(.headline)
                .foregroundStyle(color)
        }
    }
}

#Preview {
    let vm = GameViewModel()
    vm.startNewLife()
    return SavingsView(viewModel: vm)
}
