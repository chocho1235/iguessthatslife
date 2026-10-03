import SwiftUI

struct BlackjackView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    private typealias Phase = BlackjackTableView.Phase

    @State private var deck: [Card] = []
    @State private var playerCards: [Card] = []
    @State private var dealerCards: [Card] = []
    @State private var phase: Phase = .betting
    @State private var bet: Int = 0
    @State private var resultText: String?
    @State private var isDealerRevealed = false

    /// At most one split is supported: `pendingHand` holds the second hand
    /// (with its own bet) until the first is done being played, and
    /// `finishedHands` collects every hand that's stopped playing — by bust
    /// or by standing/doubling — so the dealer can resolve all of them in
    /// one pass once nobody has cards left to act on.
    @State private var pendingHand: (cards: [Card], bet: Int)?
    @State private var finishedHands: [(cards: [Card], bet: Int, busted: Bool)] = []
    @State private var hasSplit = false

    var character: Character { viewModel.character! }

    /// Only the cards that count toward the displayed dealer total right
    /// now — the hole card is excluded until it's actually revealed, so the
    /// total on screen never gives away the dealer's hand early. The full
    /// `dealerCards` still gets passed down to the table so the hole card
    /// can play its flip-reveal animation instead of just popping in.
    private var visibleDealerCards: [Card] {
        isDealerRevealed ? dealerCards : Array(dealerCards.prefix(1))
    }

    var body: some View {
        Group {
            if character.age < 18 {
                CasinoAgeGateView(title: "Blackjack", onBack: { dismiss() })
            } else {
                BlackjackTableView(
                    balance: "$\(character.cash)",
                    cash: character.cash,
                    phase: phase,
                    handLabelSuffix: hasSplit ? "Hand \(finishedHands.count + 1) of 2" : nil,
                    dealer: dealerCards.map { BlackjackTableView.Card(rank: $0.rank.label, suit: $0.suit.rawValue) },
                    dealerHidden: !isDealerRevealed && dealerCards.count > 1,
                    player: playerCards.map { BlackjackTableView.Card(rank: $0.rank.label, suit: $0.suit.rawValue) },
                    dealerTotal: visibleDealerCards.isEmpty ? "" : "\(BlackjackHand.value(of: visibleDealerCards))",
                    playerTotal: playerCards.isEmpty ? "" : "\(BlackjackHand.value(of: playerCards))",
                    bet: "$\(bet)",
                    canDouble: canDouble,
                    canSplit: canSplit,
                    resultText: resultText,
                    onBack: { dismiss() },
                    onDeal: { chipIndex in withAnimation { startRound(chipIndex: chipIndex) } },
                    onHit: { withAnimation { hit() } },
                    onStand: { withAnimation { stand() } },
                    onDouble: { withAnimation { doubleDown() } },
                    onSplit: { withAnimation { split() } },
                    onNewRound: { withAnimation { resetToBetting() } }
                )
            }
        }
    }

    private var canDouble: Bool {
        phase == .playerTurn && playerCards.count == 2 && character.cash >= bet
    }

    private var canSplit: Bool {
        phase == .playerTurn && !hasSplit && playerCards.count == 2
            && playerCards[0].rank.blackjackValue == playerCards[1].rank.blackjackValue
            && character.cash >= bet
    }

    private func draw() -> Card {
        if deck.isEmpty { deck = BlackjackHand.freshShuffledDeck() }
        return deck.removeLast()
    }

    private func startRound(chipIndex: Int) {
        let amount = CasinoArt.betAmount(chipIndex: chipIndex, cash: character.cash)
        guard viewModel.placeBlackjackBet(amount) else {
            resultText = "You don't have $\(amount) to bet."
            return
        }

        bet = amount
        deck = BlackjackHand.freshShuffledDeck()
        playerCards = [draw(), draw()]
        dealerCards = [draw(), draw()]
        pendingHand = nil
        finishedHands = []
        hasSplit = false
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
            advancePastActiveHand(busted: true)
        }
    }

    private func stand() {
        advancePastActiveHand(busted: false)
    }

    private func doubleDown() {
        guard canDouble, viewModel.placeBlackjackBet(bet) else { return }
        bet *= 2
        playerCards.append(draw())
        advancePastActiveHand(busted: BlackjackHand.isBust(playerCards))
    }

    private func split() {
        guard canSplit, viewModel.placeBlackjackBet(bet) else { return }
        let first = [playerCards[0], draw()]
        let second = [playerCards[1], draw()]
        pendingHand = (second, bet)
        playerCards = first
        hasSplit = true
    }

    /// Call once the active hand is done being played (bust, stand, or a
    /// completed double). Moves on to the queued split hand if there is
    /// one, otherwise lets the dealer play out against everything finished.
    private func advancePastActiveHand(busted: Bool) {
        finishedHands.append((playerCards, bet, busted))
        if let next = pendingHand {
            pendingHand = nil
            playerCards = next.cards
            bet = next.bet
            // A fresh two-card hand might itself be worth standing on
            // immediately if it busts somehow is impossible here, so just
            // keep playing it normally.
            phase = .playerTurn
        } else {
            phase = .dealerTurn
            isDealerRevealed = true
            dealerPlayStep()
        }
    }

    /// Dealer draws one card at a time with a short pause between each, so
    /// the hand plays out rather than snapping straight to the result.
    private func dealerPlayStep() {
        let allBusted = finishedHands.allSatisfy(\.busted)
        let playerHasNatural = !hasSplit && finishedHands.count == 1 && BlackjackHand.isNatural(finishedHands[0].cards)
        if !allBusted, !playerHasNatural, BlackjackHand.value(of: dealerCards) < 17 {
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
        let dealerValue = BlackjackHand.value(of: dealerCards)
        let dealerNatural = !hasSplit && BlackjackHand.isNatural(dealerCards)

        let texts = finishedHands.map { hand -> String in
            let outcome = outcome(for: hand, dealerValue: dealerValue, dealerNatural: dealerNatural)
            return viewModel.settleBlackjack(bet: hand.bet, outcome: outcome)
        }
        resultText = texts.joined(separator: " ")
    }

    private func outcome(for hand: (cards: [Card], bet: Int, busted: Bool), dealerValue: Int, dealerNatural: Bool) -> BlackjackOutcome {
        if hand.busted { return .lose }
        let playerValue = BlackjackHand.value(of: hand.cards)
        let playerNatural = !hasSplit && finishedHands.count == 1 && BlackjackHand.isNatural(hand.cards)

        if playerNatural && dealerNatural { return .push }
        if playerNatural { return .blackjack }
        if dealerNatural { return .lose }
        if dealerValue > 21 { return .win }
        if playerValue > dealerValue { return .win }
        if playerValue == dealerValue { return .push }
        return .lose
    }

    private func resetToBetting() {
        phase = .betting
        playerCards = []
        dealerCards = []
        pendingHand = nil
        finishedHands = []
        hasSplit = false
        resultText = nil
    }
}

#Preview {
    let vm = GameViewModel()
    vm.startNewLife()
    return BlackjackView(viewModel: vm)
}
