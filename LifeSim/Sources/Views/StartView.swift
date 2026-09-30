import SwiftUI

struct StartView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("LifeSim")
                .font(.system(size: 48, weight: .bold, design: .rounded))
            Text("Live a random life, one year at a time.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
            Button {
                viewModel.startNewLife()
            } label: {
                Text("Start New Life")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
        }
    }
}

#Preview {
    StartView(viewModel: GameViewModel())
}
