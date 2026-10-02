import SwiftUI

struct BlackjackView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var deck: [Card] = []
    @State private var playerCards: [Card] = []
    @State private var dealerCards: [Card] = []
    @State private var phase: Phase = .betting
    @State private var bet: Int = 20
    @State private var resultText: String?
    @State private var isDealerRevealed = false

    private static let presets = [10, 20, 50, 100]

    private enum Phase {
        case betting
        case playerTurn
        case dealerTurn
        case roundOver
    }

    var character: Character { viewModel.character! }

    var body: some View {
        NavigationStack {
            Group {
                if character.age < 18 {
                    VStack {
                        Spacer()
                        Text("You must be 18 to play blackjack.")
                            .font(.headline)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    }
                } else {
                    VStack(spacing: 0) {
                        ScrollView {
                            tableFelt
                                .padding()
                        }
                        controls
                    }
                }
            }
            .navigationTitle("Blackjack")
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

    private var tableFelt: some View {
        VStack(spacing: 28) {
            Text("BLACKJACK PAYS 3:2 · DEALER STANDS ON 17")
                .font(.caption2.bold())
                .foregroundStyle(.white.opacity(0.75))

            handSection(title: "DEALER", cards: dealerCards, hideHoleCard: !isDealerRevealed)
            handSection(title: "YOU", cards: playerCards, hideHoleCard: false)
        }
        .padding(.vertical, 28)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    RadialGradient(
                        colors: [Color(red: 0.07, green: 0.42, blue: 0.22), Color(red: 0.03, green: 0.20, blue: 0.11)],
                        center: .center,
                        startRadius: 20,
                        endRadius: 280
                    )
                )
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color(red: 0.55, green: 0.38, blue: 0.16), lineWidth: 6)
        }
    }

    private func handSection(title: String, cards: [Card], hideHoleCard: Bool) -> some View {
        VStack(spacing: 10) {
            HStack {
                Text(title)
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.85))
                Spacer()
                if !cards.isEmpty {
                    Text(hideHoleCard ? "?" : "\(BlackjackHand.value(of: cards))")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.white.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            HStack(spacing: -16) {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    PlayingCardView(card: card, faceDown: hideHoleCard && index == 1)
                }
            }
            .frame(minHeight: 90)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var controls: some View {
        VStack(spacing: 12) {
            if let resultText {
                Text(resultText)
                    .font(.subheadline.bold())
                    .foregroundStyle(.blue)
                    .multilineTextAlignment(.center)
            }

            switch phase {
            case .betting:
                Stepper("Bet: $\(bet)", value: $bet, in: 1...1_000_000, step: 5)
                HStack {
                    ForEach(Self.presets, id: \.self) { preset in
                        Button("$\(preset)") { bet = preset }
                            .buttonStyle(.bordered)
                    }
                }
                Button {
                    withAnimation { startRound() }
                } label: {
                    Text("Deal").frame(maxWidth: .infinity).padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(character.cash < bet)

            case .playerTurn:
                HStack(spacing: 12) {
                    Button {
                        withAnimation { hit() }
                    } label: {
                        Text("Hit").frame(maxWidth: .infinity).padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)

                    Button {
                        withAnimation { stand() }
                    } label: {
                        Text("Stand").frame(maxWidth: .infinity).padding()
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)
                }

            case .dealerTurn:
                Text("Dealer is playing...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 6)

            case .roundOver:
                Button {
                    withAnimation { resetToBetting() }
                } label: {
                    Text("New Round").frame(maxWidth: .infinity).padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    private func draw() -> Card {
        if deck.isEmpty { deck = BlackjackHand.freshShuffledDeck() }
        return deck.removeLast()
    }

    private func startRound() {
        guard viewModel.placeBlackjackBet(bet) else {
            resultText = "You don't have $\(bet) to bet."
            return
        }

        deck = BlackjackHand.freshShuffledDeck()
        playerCards = [draw(), draw()]
        dealerCards = [draw(), draw()]
        isDealerRevealed = false
        resultText = nil

        if BlackjackHand.isNatural(playerCards) || BlackjackHand.isNatural(dealerCards) {
            phase = .dealerTurn
            isDealerRevealed = true
            dealerPlayStep()
        } else {
            phase = .playerTurn
        }
    }

    private func hit() {
        playerCards.append(draw())
        if BlackjackHand.isBust(playerCards) {
            isDealerRevealed = true
            phase = .roundOver
            resultText = viewModel.settleBlackjack(bet: bet, outcome: .lose)
        }
    }

    private func stand() {
        phase = .dealerTurn
        isDealerRevealed = true
        dealerPlayStep()
    }

    /// Dealer draws one card at a time with a short pause between each, so
    /// the hand plays out rather than snapping straight to the result.
    private func dealerPlayStep() {
        let playerHasNatural = BlackjackHand.isNatural(playerCards)
        let playerBusted = BlackjackHand.isBust(playerCards)
        if !playerBusted, !playerHasNatural, BlackjackHand.value(of: dealerCards) < 17 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation { dealerCards.append(draw()) }
                dealerPlayStep()
            }
        } else {
            finishRound()
        }
    }

    private func finishRound() {
        phase = .roundOver
        let playerValue = BlackjackHand.value(of: playerCards)
        let dealerValue = BlackjackHand.value(of: dealerCards)
        let playerNatural = BlackjackHand.isNatural(playerCards)
        let dealerNatural = BlackjackHand.isNatural(dealerCards)

        let outcome: BlackjackOutcome
        if playerValue > 21 {
            outcome = .lose
        } else if playerNatural && dealerNatural {
            outcome = .push
        } else if playerNatural {
            outcome = .blackjack
        } else if dealerNatural {
            outcome = .lose
        } else if dealerValue > 21 {
            outcome = .win
        } else if playerValue > dealerValue {
            outcome = .win
        } else if playerValue == dealerValue {
            outcome = .push
        } else {
            outcome = .lose
        }

        resultText = viewModel.settleBlackjack(bet: bet, outcome: outcome)
    }

    private func resetToBetting() {
        phase = .betting
        playerCards = []
        dealerCards = []
        resultText = nil
    }
}

#Preview {
    let vm = GameViewModel()
    vm.startNewLife()
    return BlackjackView(viewModel: vm)
}
