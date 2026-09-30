import SwiftUI

struct GameOverView: View {
    @ObservedObject var viewModel: GameViewModel

    var character: Character { viewModel.character! }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            AvatarView(seed: character.fullName, gender: character.gender, stage: character.stage, isAlive: false, scars: character.scars)
                .frame(width: 120, height: 120)
                .background(Color(.secondarySystemBackground))
                .clipShape(Circle())
            Text("\(character.fullName)")
                .font(.title.bold())
            Text("Died at age \(character.age)")
                .font(.headline)
                .foregroundStyle(.secondary)
            if let cause = character.causeOfDeath {
                Text("Cause: \(cause)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("Final Stats")
                    .font(.headline)
                Text("Health: \(character.stats.health)")
                Text("Happiness: \(character.stats.happiness)")
                Text("Smarts: \(character.stats.smarts)")
                Text("Looks: \(character.stats.looks)")
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.top, 12)
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
        .padding(.horizontal, 24)
    }
}

#Preview {
    let vm = GameViewModel()
    vm.startNewLife()
    vm.character?.age = 88
    vm.character?.isAlive = false
    vm.character?.causeOfDeath = "a heart attack"
    vm.isGameOver = true
    return GameOverView(viewModel: vm)
}
