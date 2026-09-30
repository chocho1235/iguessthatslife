import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        Group {
            if viewModel.character == nil {
                StartView(viewModel: viewModel)
            } else if viewModel.isGameOver {
                GameOverView(viewModel: viewModel)
            } else {
                GameView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
