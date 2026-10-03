import SwiftUI

/// Thin wrappers that connect the art-directed casino screens (`CasinoArtwork.swift`)
/// to real game state in `GameViewModel`. Each screen owns only the display
/// state (recent results, the running dice total, animation timing) — every
/// cash change goes through the view model.
///
/// All three games follow the same shape: the view model is called
/// immediately (so the outcome is known and the animation can play toward
/// it), but the result text, the win/lose chime, and re-enabling the
/// controls are all delayed until the animation actually finishes — so nothing
/// gives away the result before the player sees it land.

struct CoinFlipGameView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var lastFlips: [Bool] = []
    @State private var resultText: String?
    @State private var coinResult = true
    @State private var spinToken = 0
    @State private var isFlipping = false

    private static let flipDuration: TimeInterval = 1.05

    var character: Character { viewModel.character! }

    var body: some View {
        CoinFlipView(
            balance: "$\(character.cash)",
            cash: character.cash,
            lastFlips: lastFlips,
            resultText: resultText,
            isFlipping: isFlipping,
            coinResult: coinResult,
            spinToken: spinToken,
            onBack: { dismiss() },
            onFlip: { callHeads, chipIndex in
                guard !isFlipping else { return }
                let amount = CasinoArt.betAmount(chipIndex: chipIndex, cash: character.cash)
                let (landedHeads, text) = viewModel.flipCoin(amount, callHeads: callHeads)
                isFlipping = true
                resultText = nil
                coinResult = landedHeads
                spinToken += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + Self.flipDuration) {
                    SoundManager.shared.play(landedHeads == callHeads ? .success : .rejected)
                    withAnimation {
                        resultText = text
                        lastFlips.insert(landedHeads, at: 0)
                        if lastFlips.count > 6 { lastFlips.removeLast() }
                    }
                    isFlipping = false
                }
            }
        )
    }
}

struct RouletteGameView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var lastNumbers: [Int] = []
    @State private var ball: Int?
    @State private var resultText: String?
    @State private var spinToken = 0
    @State private var isSpinning = false

    private static let spinDuration: TimeInterval = 3.7

    var character: Character { viewModel.character! }

    var body: some View {
        RouletteView(
            balance: "$\(character.cash)",
            cash: character.cash,
            lastNumbers: lastNumbers,
            ball: ball,
            resultText: resultText,
            isSpinning: isSpinning,
            spinToken: spinToken,
            onBack: { dismiss() },
            onSpin: { bets in
                guard !isSpinning else { return }
                let total = bets.values.reduce(0, +)
                let (result, text) = viewModel.spinRoulette(bets)
                isSpinning = true
                resultText = nil
                ball = result
                spinToken += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + Self.spinDuration) {
                    let winnings = bets.reduce(0) { sum, entry in
                        entry.key.wins(for: result) ? sum + entry.value + entry.value * entry.key.payoutMultiple : sum
                    }
                    SoundManager.shared.play(winnings > total ? .success : (winnings > 0 ? .tap : .rejected))
                    withAnimation {
                        resultText = text
                        lastNumbers.insert(result, at: 0)
                        if lastNumbers.count > 8 { lastNumbers.removeLast() }
                    }
                    isSpinning = false
                }
            }
        )
    }
}

struct HighLowGameView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var dice: (Int, Int) = (Int.random(in: 1...6), Int.random(in: 1...6))
    @State private var resultText: String?
    @State private var rollToken = 0
    @State private var isRolling = false

    private static let rollDuration: TimeInterval = 0.95

    var character: Character { viewModel.character! }

    var body: some View {
        HighLowDiceView(
            balance: "$\(character.cash)",
            cash: character.cash,
            dice: dice,
            resultText: resultText,
            isRolling: isRolling,
            rollToken: rollToken,
            onBack: { dismiss() },
            onRoll: { guessHigher, chipIndex in
                guard !isRolling else { return }
                let amount = CasinoArt.betAmount(chipIndex: chipIndex, cash: character.cash)
                let previousTotal = dice.0 + dice.1
                let (newDice, text) = viewModel.rollHighOrLow(amount, previousTotal: previousTotal, guessHigher: guessHigher)
                isRolling = true
                resultText = nil
                dice = newDice
                rollToken += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + Self.rollDuration) {
                    let newTotal = newDice.0 + newDice.1
                    let sound: SoundEffect = newTotal == previousTotal ? .tap : ((newTotal > previousTotal) == guessHigher ? .success : .rejected)
                    SoundManager.shared.play(sound)
                    withAnimation { resultText = text }
                    isRolling = false
                }
            }
        )
    }
}
