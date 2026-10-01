import SwiftUI

struct StartView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.90, green: 0.98, blue: 0.94),
                    Color(.systemBackground),
                    Color(red: 0.94, green: 0.96, blue: 1.00),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer(minLength: 20)

                VStack(spacing: 8) {
                    Text("I Guess That's Life")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                    Text("A whole random life is waiting.")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(
                            AngularGradient(
                                colors: [.green, .mint, .blue, .purple, .pink, .orange, .green],
                                center: .center
                            )
                        )
                        .frame(width: 180, height: 180)
                        .blur(radius: 10)
                        .opacity(0.55)

                    Circle()
                        .fill(.white.opacity(0.85))
                        .frame(width: 172, height: 172)
                        .shadow(color: .black.opacity(0.16), radius: 22, y: 12)

                    AvatarView(seed: "Alex Tomorrow", gender: .female, stage: .teen)
                        .frame(width: 156, height: 156)

                    Image(systemName: "sparkles")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(
                            LinearGradient(colors: [Color(red: 1.0, green: 0.5, blue: 0.4), Color(red: 0.95, green: 0.3, blue: 0.5)], startPoint: .top, endPoint: .bottom)
                        )
                        .clipShape(Circle())
                        .overlay { Circle().stroke(.white, lineWidth: 3) }
                        .shadow(color: .pink.opacity(0.4), radius: 8, y: 3)
                }

                VStack(spacing: 10) {
                    Text("Every year can change everything.")
                        .font(.subheadline.bold())
                    HStack(spacing: 8) {
                        StartStatPill(label: "Health", systemImage: "heart.fill", color: .red)
                        StartStatPill(label: "Cash", systemImage: "dollarsign.circle.fill", color: .green)
                        StartStatPill(label: "Friends", systemImage: "person.2.fill", color: .blue)
                    }
                }

                Spacer(minLength: 16)

                Button {
                    SoundManager.shared.play(.ageUp)
                    viewModel.startNewLife()
                } label: {
                    Text("Start New Life")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [Color(red: 0.25, green: 0.78, blue: 0.5), Color(red: 0.14, green: 0.62, blue: 0.4)], startPoint: .top, endPoint: .bottom)
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(.white.opacity(0.25), lineWidth: 1)
                        }
                        .shadow(color: .green.opacity(0.35), radius: 16, y: 8)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 42)
            }
            .padding(.horizontal, 18)
        }
    }
}

private struct StartStatPill: View {
    let label: String
    let systemImage: String
    let color: Color

    var body: some View {
        Label(label, systemImage: systemImage)
            .font(.caption.bold())
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background(Color(.systemBackground).opacity(0.78))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(color.opacity(0.18), lineWidth: 1)
            }
    }
}

#Preview {
    StartView(viewModel: GameViewModel())
}
