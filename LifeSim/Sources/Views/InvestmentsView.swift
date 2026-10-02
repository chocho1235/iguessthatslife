import SwiftUI

struct InvestmentsView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var feedback: String?
    @State private var quantities: [String: Int] = [:]

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

                Section {
                    HStack {
                        Text("Portfolio value")
                        Spacer()
                        Text("$\(portfolioValue)")
                            .font(.headline)
                            .foregroundStyle(.green)
                    }
                    Text("Prices move every year you age up. Hold on through the dips, or cash out whenever you like.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Market") {
                    ForEach(StockData.all) { stock in
                        row(for: stock)
                    }
                }
            }
            .navigationTitle("Investments")
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

    private var portfolioValue: Int {
        StockData.all.reduce(0) { total, stock in
            let shares = character.stockHoldings[stock.id] ?? 0
            guard shares > 0 else { return total }
            return total + Int(viewModel.stockPrice(for: stock, character: character) * Double(shares))
        }
    }

    private func quantity(for stock: Stock) -> Int {
        quantities[stock.id] ?? 1
    }

    @ViewBuilder
    private func row(for stock: Stock) -> some View {
        let price = viewModel.stockPrice(for: stock, character: character)
        let owned = character.stockHoldings[stock.id] ?? 0
        let qty = quantity(for: stock)
        let buyCost = Int((price * Double(qty)).rounded(.up))

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(stock.symbol).font(.subheadline.bold())
                        Text(stock.name).font(.caption).foregroundStyle(.secondary)
                    }
                    Text("$\(String(format: "%.2f", price)) / share")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if owned > 0 {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(owned) share\(owned == 1 ? "" : "s")")
                            .font(.caption.bold())
                        Text("$\(Int(price * Double(owned)))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Stepper("Trade \(qty) share\(qty == 1 ? "" : "s")", value: Binding(
                get: { quantity(for: stock) },
                set: { quantities[stock.id] = max(1, $0) }
            ), in: 1...9999)
            .font(.caption)

            HStack {
                Button("Buy ($\(buyCost))") {
                    withAnimation { feedback = viewModel.buyStock(stock, shares: qty) }
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(character.cash < buyCost)

                Button("Sell") {
                    withAnimation { feedback = viewModel.sellStock(stock, shares: qty) }
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .disabled(owned < qty)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let vm = GameViewModel()
    vm.startNewLife()
    return InvestmentsView(viewModel: vm)
}
