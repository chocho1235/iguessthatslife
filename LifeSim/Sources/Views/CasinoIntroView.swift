import SwiftUI

/// A staged, auto-playing marquee animation shown before the casino itself —
/// title card, neon sign, a fan of cards, chips, a spinning 7-7-7 slot
/// readout, and a coin shower, built entirely from shapes and text to match
/// the rest of the game's no-image-assets style.
struct CasinoIntroView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var step = 0
    @State private var reelDigits = [7, 7, 7]
    @State private var coins: [CoinConfig] = []
    @State private var playToken = UUID()
    @State private var enteringCasino = false

    private enum Palette {
        static let feltDark = Color(red: 0.02, green: 0.05, blue: 0.03)
        static let feltGlow = Color(red: 0.08, green: 0.35, blue: 0.22)
        static let neonPink = Color(red: 1.0, green: 0.28, blue: 0.47)
        static let gold = Color(red: 0.96, green: 0.77, blue: 0.26)
        static let cream = Color(red: 0.98, green: 0.97, blue: 0.94)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                background

                VStack(spacing: 22) {
                    titleBlock
                        .opacity(step >= 1 ? 1 : 0)
                        .offset(y: step >= 1 ? 0 : -14)

                    marquee
                        .opacity(step >= 2 ? 1 : 0)
                        .scaleEffect(step >= 2 ? 1 : 0.85)

                    cardsRow
                        .opacity(step >= 3 ? 1 : 0)
                        .offset(y: step >= 3 ? 0 : 24)

                    slotMachine
                        .opacity(step >= 5 ? 1 : 0)
                        .scaleEffect(step >= 5 ? 1 : 0.9)

                    if step >= 6 {
                        Text("Feeling lucky?")
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                            .transition(.opacity)
                    }

                    if step >= 7 {
                        buttonsRow
                            .transition(.opacity)
                    }

                    Spacer(minLength: 0)
                }
                .padding(.top, 50)
                .padding(.horizontal, 24)

                ForEach(coins) { coin in
                    CoinParticle(xOffset: coin.x, delay: coin.delay)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Skip") { skipIntro() }
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear { playIntro() }
            .navigationDestination(isPresented: $enteringCasino) {
                CasinoView(viewModel: viewModel)
            }
        }
    }

    // MARK: - Sections

    private var background: some View {
        ZStack {
            RadialGradient(colors: [Palette.feltGlow, Palette.feltDark], center: .center, startRadius: 10, endRadius: 420)
                .ignoresSafeArea()
            beam.rotationEffect(.degrees(22)).offset(x: -70, y: -220)
            beam.rotationEffect(.degrees(-22)).offset(x: 70, y: -220)
        }
    }

    private var beam: some View {
        Rectangle()
            .fill(LinearGradient(colors: [.white.opacity(0.08), .clear], startPoint: .top, endPoint: .bottom))
            .frame(width: 160, height: 760)
            .blendMode(.plusLighter)
    }

    private var titleBlock: some View {
        VStack(spacing: 4) {
            Text("JUST LIFE")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .tracking(6)
                .foregroundStyle(.white.opacity(0.9))
            Text("PRESENTS")
                .font(.caption2.bold())
                .tracking(4)
                .foregroundStyle(Palette.gold)
        }
    }

    private var marquee: some View {
        VStack(spacing: 6) {
            Text("CASINO")
                .font(.system(size: 38, weight: .heavy, design: .rounded))
                .foregroundStyle(Palette.neonPink)
                .shadow(color: Palette.neonPink.opacity(0.8), radius: 6)
                .shadow(color: Palette.neonPink.opacity(0.5), radius: 16)
            Text("THE JUST LIFE CASINO")
                .font(.caption2.bold())
                .tracking(2)
                .foregroundStyle(Palette.cream.opacity(0.85))
        }
        .padding(.vertical, 22)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.25))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Palette.gold, lineWidth: 3)
        }
        .overlay(alignment: .top) { bulbRow.offset(y: -1) }
        .overlay(alignment: .bottom) { bulbRow.offset(y: 1) }
    }

    private var bulbRow: some View {
        HStack(spacing: 14) {
            ForEach(0..<9, id: \.self) { _ in
                Circle()
                    .fill(Palette.gold)
                    .frame(width: 5, height: 5)
                    .shadow(color: Palette.gold.opacity(0.8), radius: 3)
            }
        }
        .padding(.horizontal, 18)
    }

    private var cardsRow: some View {
        ZStack {
            HStack(spacing: -18) {
                PlayingCardView(card: Card(suit: .spades, rank: .ace))
                    .rotationEffect(.degrees(-12))
                    .offset(y: 10)
                PlayingCardView(card: Card(suit: .hearts, rank: .king))
                    .zIndex(1)
                PlayingCardView(card: Card(suit: .diamonds, rank: .queen))
                    .rotationEffect(.degrees(12))
                    .offset(y: 10)
            }

            if step >= 4 {
                HStack {
                    ChipStackView(colors: [Palette.gold, .red])
                    Spacer()
                    ChipStackView(colors: [.blue, Palette.gold])
                }
                .padding(.horizontal, -14)
                .transition(.opacity)
            }
        }
    }

    private var slotMachine: some View {
        HStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { index in
                Text("\(reelDigits[index])")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundStyle(Palette.neonPink)
                    .frame(width: 46, height: 58)
                    .background(Palette.cream)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(red: 0.12, green: 0.06, blue: 0.04)))
        .overlay {
            RoundedRectangle(cornerRadius: 16).stroke(Palette.gold, lineWidth: 3)
        }
    }

    private var buttonsRow: some View {
        HStack(spacing: 14) {
            Button {
                enteringCasino = true
            } label: {
                Text("Enter Casino")
                    .font(.headline.bold())
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Palette.gold)
                    .foregroundStyle(.black)
                    .clipShape(Capsule())
            }

            Button {
                playIntro()
            } label: {
                Text("Replay")
                    .font(.headline.bold())
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .overlay(Capsule().stroke(Palette.gold, lineWidth: 2))
                    .foregroundStyle(.white)
            }
        }
    }

    // MARK: - Sequencing

    private func playIntro() {
        let token = UUID()
        playToken = token
        step = 0
        coins = []
        reelDigits = [7, 7, 7]

        func after(_ delay: Double, _ action: @escaping () -> Void) {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard playToken == token else { return }
                action()
            }
        }

        withAnimation(.easeOut(duration: 0.6)) { step = 1 }
        after(0.9) { withAnimation(.easeOut(duration: 0.6)) { step = 2 } }
        after(1.6) { withAnimation(.spring()) { step = 3 } }
        after(2.1) { withAnimation(.easeOut(duration: 0.5)) { step = 4 } }
        after(2.5) {
            withAnimation(.easeOut(duration: 0.4)) { step = 5 }
            spinReels(token: token)
        }
        after(3.4) {
            coins = (0..<12).map { _ in CoinConfig(x: CGFloat.random(in: -140...140), delay: Double.random(in: 0...0.5)) }
            withAnimation(.easeOut(duration: 0.5)) { step = 6 }
        }
        after(3.9) { withAnimation(.easeOut(duration: 0.5)) { step = 7 } }
    }

    private func skipIntro() {
        playToken = UUID()
        reelDigits = [7, 7, 7]
        coins = (0..<12).map { _ in CoinConfig(x: CGFloat.random(in: -140...140), delay: Double.random(in: 0...0.3)) }
        withAnimation { step = 7 }
    }

    /// Each reel flickers through random digits before settling on 7, with
    /// the reels stopping one after another like a real slot machine.
    private func spinReels(token: UUID) {
        for index in 0..<3 {
            spinReel(index: index, stopDelay: 0.4 + Double(index) * 0.3, token: token)
        }
    }

    private func spinReel(index: Int, stopDelay: Double, token: UUID) {
        let start = Date()
        func tick() {
            guard playToken == token else { return }
            if Date().timeIntervalSince(start) >= stopDelay {
                reelDigits[index] = 7
                return
            }
            reelDigits[index] = Int.random(in: 0...9)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08, execute: tick)
        }
        tick()
    }
}

private struct ChipStackView: View {
    let colors: [Color]

    var body: some View {
        ZStack {
            ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                Circle()
                    .fill(color)
                    .frame(width: 32, height: 32)
                    .overlay {
                        Circle().strokeBorder(Color(red: 0.96, green: 0.77, blue: 0.26), style: StrokeStyle(lineWidth: 2, dash: [3, 3]))
                    }
                    .offset(y: -CGFloat(index) * 6)
            }
        }
    }
}

private struct CoinConfig: Identifiable {
    let id = UUID()
    let x: CGFloat
    let delay: Double
}

private struct CoinParticle: View {
    let xOffset: CGFloat
    let delay: Double
    @State private var animate = false

    var body: some View {
        Text("🪙")
            .font(.system(size: CGFloat.random(in: 16...24)))
            .offset(x: xOffset, y: animate ? 480 : -420)
            .opacity(animate ? 0 : 1)
            .rotationEffect(.degrees(animate ? 180 : 0))
            .onAppear {
                withAnimation(.easeIn(duration: 1.6).delay(delay)) {
                    animate = true
                }
            }
    }
}

#Preview {
    let vm = GameViewModel()
    vm.startNewLife()
    return CasinoIntroView(viewModel: vm)
}
