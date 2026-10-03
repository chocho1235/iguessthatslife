import SwiftUI

/// The casino lobby — a grid of tables rather than a plain list, each
/// pushing its own fully art-directed game screen.
struct CasinoView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var path: [CasinoGame] = []

    var character: Character { viewModel.character! }

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if character.age < 18 {
                    CasinoAgeGateView(title: "Casino", onBack: { dismiss() })
                } else {
                    CasinoLobbyView(
                        balance: "$\(character.cash)",
                        onBack: { dismiss() },
                        onSelect: { game in path.append(game) }
                    )
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: CasinoGame.self) { game in
                switch game {
                case .coinFlip:
                    CoinFlipGameView(viewModel: viewModel).toolbar(.hidden, for: .navigationBar)
                case .blackjack:
                    BlackjackView(viewModel: viewModel).toolbar(.hidden, for: .navigationBar)
                case .roulette:
                    RouletteGameView(viewModel: viewModel).toolbar(.hidden, for: .navigationBar)
                case .dice:
                    HighLowGameView(viewModel: viewModel).toolbar(.hidden, for: .navigationBar)
                }
            }
        }
    }
}

#Preview {
    let vm = GameViewModel()
    vm.startNewLife()
    return CasinoView(viewModel: vm)
}
