//
//  CasinoAnimations.swift
//  Just Life
//
//  Animated versions of the static artwork pieces in CasinoArtwork.swift.
//  Each view here owns its own short-lived animation state and is driven by
//  bumping a `spinToken`/`rollToken` integer once the caller already knows
//  the true outcome — the component animates *toward* that known result
//  rather than picking its own, so the visual always lands correctly.
//

import SwiftUI

// MARK: - Shared flip effect

/// A `ViewModifier` that applies a 3D rotation and, on every interpolated
/// frame of the animation, reports the current normalized angle (0..<360)
/// back to the caller. That callback is how a coin or card can swap its
/// displayed face exactly when it's edge-on to the viewer, instead of
/// snapping instantly or showing a mirrored back face.
private struct AxisFlip: ViewModifier, Animatable {
    var angle: Double
    var axis: (x: CGFloat, y: CGFloat, z: CGFloat)
    var onFrame: (Double) -> Void

    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    func body(content: Content) -> some View {
        let normalized = angle.truncatingRemainder(dividingBy: 360)
        let positive = normalized < 0 ? normalized + 360 : normalized
        DispatchQueue.main.async { onFrame(positive) }
        return content.rotation3DEffect(.degrees(angle), axis: axis, perspective: 0.45)
    }
}

// MARK: - Coin flip

/// A coin that tumbles end over end and always settles on `result`. Bump
/// `spinToken` to trigger a fresh flip.
struct FlippingCoinView: View {
    var size: CGFloat
    var result: Bool // true = heads
    var spinToken: Int

    @State private var rotation: Double = 0
    @State private var showingHeads = true

    var body: some View {
        GoldCoin(size: size, caption: showingHeads ? "HEADS" : "TAILS")
            .modifier(AxisFlip(angle: rotation, axis: (x: 1, y: 0, z: 0)) { normalized in
                showingHeads = normalized < 90 || normalized > 270
            })
            .onAppear {
                showingHeads = result
                rotation = result ? 0 : 180
            }
            .onChange(of: spinToken) { _, _ in flip() }
    }

    private func flip() {
        let spins = Double(Int.random(in: 4...6))
        let currentPositive = normalize(rotation)
        let target: Double = result ? 0 : 180
        let delta = normalize(target - currentPositive)
        withAnimation(.easeOut(duration: 1.0)) {
            rotation += spins * 360 + delta
        }
    }

    private func normalize(_ angle: Double) -> Double {
        let m = angle.truncatingRemainder(dividingBy: 360)
        return m < 0 ? m + 360 : m
    }
}

// MARK: - Tumbling die

/// A die that rattles through random faces before settling on `finalValue`.
/// Bump `rollToken` to trigger a fresh roll.
struct TumblingDieView: View {
    var finalValue: Int
    var size: CGFloat = 116
    var color: Color = CasinoArt.hex(0xC8243A)
    var rollToken: Int

    @State private var displayValue: Int
    @State private var wobble: Double = 0
    @State private var rollID = UUID()

    init(finalValue: Int, size: CGFloat = 116, color: Color = CasinoArt.hex(0xC8243A), rollToken: Int) {
        self.finalValue = finalValue
        self.size = size
        self.color = color
        self.rollToken = rollToken
        _displayValue = State(initialValue: finalValue)
    }

    var body: some View {
        DieFace(value: displayValue, size: size, color: color)
            .rotation3DEffect(.degrees(wobble), axis: (x: 0.35, y: 1, z: 0.12))
            .onChange(of: rollToken) { _, _ in roll() }
    }

    private func roll() {
        let id = UUID()
        rollID = id
        let duration = 0.85
        let start = Date()

        func tick() {
            guard rollID == id else { return }
            let elapsed = Date().timeIntervalSince(start)
            guard elapsed < duration else {
                displayValue = finalValue
                withAnimation(.easeOut(duration: 0.18)) { wobble = 0 }
                return
            }
            displayValue = Int.random(in: 1...6)
            withAnimation(.easeInOut(duration: 0.09)) { wobble = Double.random(in: -20...20) }
            let progress = elapsed / duration
            let interval = 0.045 + progress * 0.1
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) { tick() }
        }
        tick()
    }
}

// MARK: - Spinning roulette wheel

/// Wraps the static `RouletteWheel` artwork with a wheel spin and an
/// independently animated ball that converges on `result`'s pocket. Bump
/// `spinToken` to trigger a fresh spin; the wheel keeps its resting
/// rotation between spins so it never snaps back to a start position.
struct SpinningRouletteWheelView: View {
    var size: CGFloat = 220
    var result: Int?
    var spinToken: Int

    @State private var wheelRotation: Double = 0
    @State private var ballAngle: Double = 0
    @State private var showBall = false

    var body: some View {
        ZStack {
            RouletteWheel(size: size, showNumbers: true, ball: nil)
                .rotationEffect(.degrees(wheelRotation))
            if showBall {
                Circle()
                    .fill(RadialGradient(colors: [.white, CasinoArt.hex(0xD8D8D8)], center: UnitPoint(x: 0.35, y: 0.3), startRadius: 0, endRadius: 6))
                    .frame(width: size * 0.048, height: size * 0.048)
                    .shadow(color: .black.opacity(0.6), radius: 2, y: 2)
                    .offset(y: -size * 0.32)
                    .rotationEffect(.degrees(ballAngle))
            }
        }
        .shadow(color: .black.opacity(0.6), radius: 20, y: 16)
        .onAppear {
            guard let result, !showBall else { return }
            ballAngle = pocketAngle(for: result) + wheelRotation
            showBall = true
        }
        .onChange(of: spinToken) { _, _ in
            guard let result else { return }
            spin(to: result)
        }
    }

    private func pocketAngle(for number: Int) -> Double {
        guard let i = RouletteNumbers.wheelOrder.firstIndex(of: number) else { return 0 }
        return Double(i) * (360.0 / 37.0)
    }

    private func spin(to result: Int) {
        let wheelSpins = Double(Int.random(in: 2...3))
        let wheelTarget = wheelRotation + wheelSpins * 360 + Double.random(in: 0..<360)
        let ballFinalScreenAngle = pocketAngle(for: result) + wheelTarget

        let currentMod = normalize(ballAngle)
        let desiredMod = normalize(ballFinalScreenAngle)
        let diff = normalize(currentMod - desiredMod)
        let ballSpins = Double(Int.random(in: 6...9))
        let ballTarget = ballAngle - ballSpins * 360 - diff

        showBall = true
        withAnimation(.timingCurve(0.15, 0.85, 0.3, 1, duration: 3.6)) {
            wheelRotation = wheelTarget
        }
        withAnimation(.timingCurve(0.08, 0.85, 0.2, 1, duration: 3.6)) {
            ballAngle = ballTarget
        }
    }

    private func normalize(_ angle: Double) -> Double {
        let m = angle.truncatingRemainder(dividingBy: 360)
        return m < 0 ? m + 360 : m
    }
}

// MARK: - Card reveal flip

/// Used for the dealer's hole card: shows a card back, then flips over to
/// reveal the real face once `isRevealed` becomes true.
struct RevealingCardView: View {
    var rank: String
    var suit: String
    var width: CGFloat = 84
    var isRevealed: Bool

    @State private var rotation: Double = 0
    @State private var showingFace = false

    var body: some View {
        Group {
            if showingFace {
                CasinoCardFace(rank: rank, suit: suit, width: width)
            } else {
                CasinoCardBack(width: width)
            }
        }
        .modifier(AxisFlip(angle: rotation, axis: (x: 0, y: 1, z: 0)) { normalized in
            showingFace = normalized > 90 && normalized < 270
        })
        .onAppear { showingFace = isRevealed }
        .onChange(of: isRevealed) { _, revealed in
            guard revealed else { return }
            withAnimation(.easeInOut(duration: 0.5)) { rotation = 180 }
        }
    }
}
