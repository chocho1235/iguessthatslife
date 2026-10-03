import SwiftUI

/// Thin wrappers that connect the art-directed casino screens (`CasinoArtwork.swift`)
/// to real game state in `GameViewModel`. Each screen owns only the display
/// state (recent results, the running dice total) — every cash change goes
/// through the view model.

struct CoinFlipGameView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var lastFlips: [Bool] = []
    @State private var resultText: String?

    var character: Character { viewModel.character! }

    var body: some View {
        CoinFlipView(
            balance: "$\(character.cash)",
            cash: character.cash,
            lastFlips: lastFlips,
            resultText: resultText,
            onBack: { dismiss() },
            onFlip: { callHeads, chipIndex in
                let amount = CasinoArt.betAmount(chipIndex: chipIndex, cash: character.cash)
                let (landedHeads, text) = viewModel.flipCoin(amount, callHeads: callHeads)
                withAnimation {
                    resultText = text
                    lastFlips.insert(landedHeads, at: 0)
                    if lastFlips.count > 6 { lastFlips.removeLast() }
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

    var character: Character { viewModel.character! }

    var body: some View {
        RouletteView(
            balance: "$\(character.cash)",
            cash: character.cash,
            lastNumbers: lastNumbers,
            ball: ball,
            resultText: resultText,
            onBack: { dismiss() },
            onSpin: { bets in
                let (result, text) = viewModel.spinRoulette(bets)
                withAnimation {
                    ball = result
                    resultText = text
                    lastNumbers.insert(result, at: 0)
                    if lastNumbers.count > 8 { lastNumbers.removeLast() }
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

    var character: Character { viewModel.character! }

    var body: some View {
        HighLowDiceView(
            balance: "$\(character.cash)",
            cash: character.cash,
            dice: dice,
            resultText: resultText,
            onBack: { dismiss() },
            onRoll: { guessHigher, chipIndex in
                let amount = CasinoArt.betAmount(chipIndex: chipIndex, cash: character.cash)
                let previousTotal = dice.0 + dice.1
                let (newDice, text) = viewModel.rollHighOrLow(amount, previousTotal: previousTotal, guessHigher: guessHigher)
                withAnimation {
                    dice = newDice
                    resultText = text
                }
            }
        )
    }
}
