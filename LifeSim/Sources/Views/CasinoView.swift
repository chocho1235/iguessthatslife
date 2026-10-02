import SwiftUI

struct CasinoView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var bet: Int = 20
    @State private var feedback: String?

    private static let presets = [10, 20, 50, 100]

    var character: Character { viewModel.character! }

    var body: some View {
        NavigationStack {
            List {
                if character.age < 18 {
                    Section {
                        Text("You must be 18 to gamble. Come back when you're older.")
                            .font(.subheadline.bold())
                            .foregroundStyle(.red)
                    }
                } else {
                    if let feedback {
                        Section {
                            Text(feedback)
                                .font(.subheadline.bold())
                                .foregroundStyle(.blue)
                        }
                    }

                    Section("Bet Amount") {
                        Stepper("Bet: $\(bet)", value: $bet, in: 1...1_000_000, step: 5)
                        HStack {
                            ForEach(Self.presets, id: \.self) { preset in
                                Button("$\(preset)") { bet = preset }
                                    .buttonStyle(.bordered)
                            }
                        }
                    }

                    Section("Table Games") {
                        NavigationLink {
                            BlackjackView(viewModel: viewModel)
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "suit.spade.fill")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.green.gradient)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Blackjack").font(.subheadline.bold())
                                    Text("Real cards, real table. Beat the dealer to 21.")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    Section("Quick Games") {
                        ForEach(GambleGame.allCases) { game in
                            gameRow(game)
                        }
                    }

                    Section {
                        Text("The house usually wins. Only bet what you can afford to lose.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Casino")
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

    private func gameRow(_ game: GambleGame) -> some View {
        HStack(spacing: 14) {
            Image(systemName: game.icon)
                .font(.title2)
                .foregroundStyle(.purple)
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(game.rawValue).font(.subheadline.bold())
                Text(game.subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Play") {
                withAnimation { feedback = viewModel.gamble(bet, game: game) }
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
            .disabled(character.cash < bet)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let vm = GameViewModel()
    vm.startNewLife()
    return CasinoView(viewModel: vm)
}
