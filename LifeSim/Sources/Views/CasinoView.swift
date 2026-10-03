import SwiftUI

/// The casino lobby — a grid of tables rather than a plain list, each
/// pushing its own fully art-directed game screen. Uses the navigation
/// stack it was pushed onto rather than creating a nested one, which is
/// what made entry bounce back to the Bank.
struct CasinoView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedGame: CasinoGame?

    var character: Character { viewModel.character! }

    private var gamePresented: Binding<Bool> {
        Binding(
            get: { selectedGame != nil },
            set: { if !$0 { selectedGame = nil } }
        )
    }

    var body: some View {
        Group {
            if character.age < 18 {
                CasinoAgeGateView(title: "Casino", onBack: { dismiss() })
            } else {
                CasinoLobbyView(
                    balance: "$\(character.cash)",
                    onBack: { dismiss() },
                    onSelect: { game in selectedGame = game }
                )
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: gamePresented) {
            gameScreen(for: selectedGame)
                .toolbar(.hidden, for: .navigationBar)
        }
    }

    @ViewBuilder
    private func gameScreen(for game: CasinoGame?) -> some View {
        switch game {
        case .coinFlip:
            CoinFlipGameView(viewModel: viewModel)
        case .blackjack:
            BlackjackView(viewModel: viewModel)
        case .roulette:
            RouletteGameView(viewModel: viewModel)
        case .dice:
            HighLowGameView(viewModel: viewModel)
        case .none:
            EmptyView()
        }
    }
}

#Preview {
    let vm = GameViewModel()
    vm.startNewLife()
    return CasinoView(viewModel: vm)
}
