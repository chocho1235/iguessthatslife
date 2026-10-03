//
//  CasinoIntroView.swift
//  Just Life
//
//  Short intro that plays when the player taps Casino.
//  Everything is driven by one clock (TimelineView), so the picture always lines up
//  with the two bundled sound files:
//    casino_intro_sfx.wav    one shot effects (neon, cards, chips, reels, jackpot)
//    casino_intro_music.wav  swing jazz loop, keeps going on the end screen
//  Add both .wav files to the app target (Copy Bundle Resources).
//
//  Usage:
//    CasinoIntroView(onEnter: { showCasino = true })
//

import SwiftUI
import AVFoundation

// MARK: - Audio

final class CasinoIntroAudio: ObservableObject {
    private let sfx: AVAudioPlayer?
    private let music: AVAudioPlayer?

    init() {
        sfx = Self.load("casino_intro_sfx")
        music = Self.load("casino_intro_music")
        music?.numberOfLoops = -1
    }

    private static func load(_ name: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav"),
              let player = try? AVAudioPlayer(contentsOf: url) else { return nil }
        player.prepareToPlay()
        return player
    }

    /// Starts both tracks together, `delay` seconds from now.
    func play(delay: TimeInterval, effectsVolume: Float = 1, musicVolume: Float = 1) {
        for (player, volume) in [(sfx, effectsVolume), (music, musicVolume)] {
            guard let player else { continue }
            player.stop()
            player.currentTime = 0
            player.volume = volume
        }
        guard let clock = sfx?.deviceCurrentTime ?? music?.deviceCurrentTime else { return }
        sfx?.play(atTime: clock + delay)
        music?.play(atTime: clock + delay)
    }

    /// Used by Skip: the effects fade out, the music carries on.
    func silenceEffects() {
        sfx?.setVolume(0, fadeDuration: 0.1)
    }

    func stop() {
        sfx?.stop()
        guard let music, music.isPlaying else { return }
        music.setVolume(0, fadeDuration: 0.3)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { music.stop() }
    }
}

// MARK: - View

struct CasinoIntroView: View {
    var neon: Color = introColor(0xFF3B6B)
    var playSound: Bool = true
    var onEnter: () -> Void = {}

    @StateObject private var audio = CasinoIntroAudio()
    @State private var startDate = Date()
    @State private var skipOffset: TimeInterval = 0
    @State private var skipped = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let audioDelay: TimeInterval = 0.05
    private static let endTime: TimeInterval = 6.0

    private let gold = introColor(0xF5C542)
    private let cream = introColor(0xF4EFE2)
    private let paper = introColor(0xFBF8F0)
    private let red = introColor(0xD6283B)

    var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSince(startDate) + skipOffset
            ZStack {
                introColor(0x07090A)
                    .ignoresSafeArea()
                RadialGradient(colors: [introColor(0x17603E), introColor(0x0B2D1E), introColor(0x050807)],
                               center: UnitPoint(x: 0.5, y: 0.42), startRadius: 0, endRadius: 560)
                    .opacity(easeOut(prog(t, 0, 0.7)))
                    .ignoresSafeArea()

                // the scene is laid out on a 390 x 844 stage and scaled to fit the safe area
                GeometryReader { geo in
                    let scale = min(geo.size.width / 390, geo.size.height / 844)
                    stage(t)
                        .frame(width: 390, height: 844)
                        .scaleEffect(scale)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }

                // soft flash on the win
                introColor(0xFFF4C8)
                    .opacity(keys(easeOut(prog(t, 3.42, 0.7)), [(0, 0), (0.18, 0.35), (1, 0)]))
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
            .overlay(alignment: .topTrailing) {
                if t < 4 && !skipped {
                    Button("Skip", action: skip)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(cream)
                        .padding(.horizontal, 16)
                        .frame(minHeight: 44)
                        .background(Capsule().fill(Color.black.opacity(0.4)))
                        .overlay(Capsule().stroke(cream.opacity(0.35), lineWidth: 1))
                        .padding(12)
                        .accessibilityLabel("Skip intro")
                }
            }
        }
        .onAppear(perform: restart)
        .onDisappear { audio.stop() }
    }

    // MARK: Stage (390 x 844 design space)

    @ViewBuilder
    private func stage(_ t: Double) -> some View {
        ZStack {
            beam(t, left: true)
            beam(t, left: false)
            brand(t)
            sign(t)
            cards(t)
            chips(t)
            slotMachine(t)
            coins(t)
            ending(t)
        }
    }

    private func beam(_ t: Double, left: Bool) -> some View {
        let p = easeOut(prog(t, 0.15, 1.7))
        let angle = left ? lerp(-40, 10, p) : lerp(40, -10, p)
        return BeamShape()
            .fill(LinearGradient(stops: [.init(color: introColor(0xFFF0C8).opacity(0.55), location: 0),
                                         .init(color: introColor(0xFFF0C8).opacity(0), location: 0.8)],
                                 startPoint: .top, endPoint: .bottom))
            .frame(width: 150, height: 980)
            .rotationEffect(.degrees(angle), anchor: .top)
            .opacity(keys(p, [(0, 0), (0.35, 0.5), (1, 0.16)]))
            .blendMode(.screen)
            .position(x: left ? 105 : 285, y: 430)
            .allowsHitTesting(false)
    }

    private func brand(_ t: Double) -> some View {
        let p = easeOut(prog(t, 0.15, 0.5))
        return VStack(spacing: 4) {
            Text("JUST LIFE")
                .font(.system(size: 24, weight: .heavy))
                .tracking(8)
                .foregroundStyle(cream)
            Text("PRESENTS")
                .font(.system(size: 11, weight: .semibold))
                .tracking(4.4)
                .foregroundStyle(gold)
        }
        .opacity(p)
        .offset(y: 18 * (1 - p))
        .position(x: 195, y: 70)
    }

    private func sign(_ t: Double) -> some View {
        let pop = easeOut(prog(t, 0.55, 0.5))
        let flicker = keys(prog(t, 0.6, 0.8),
                           [(0, 0), (0.08, 1), (0.12, 0.1), (0.22, 1), (0.3, 0.2),
                            (0.45, 1), (0.52, 0.5), (0.6, 1), (1, 1)])
        let pulse = t > 1.6 ? 0.5 - 0.5 * cos(2 * .pi * (t - 1.6) / 2.4) : 0
        let sub = easeOut(prog(t, 1.2, 0.4))

        return VStack(spacing: 0) {
            bulbRow(t)
            Spacer(minLength: 0)
            Text("CASINO")
                .font(.system(size: 52, weight: .black, design: .rounded))
                .tracking(6)
                .foregroundStyle(neon)
                .shadow(color: neon, radius: 3)
                .shadow(color: neon, radius: 9)
                .shadow(color: neon, radius: 21)
                .brightness(0.12 * pulse)
                .opacity(flicker)
            Text("THE JUST LIFE CASINO")
                .font(.system(size: 12, weight: .semibold))
                .tracking(3.8)
                .foregroundStyle(gold)
                .opacity(sub)
                .offset(y: 18 * (1 - sub))
                .padding(.top, 8)
            Spacer(minLength: 0)
            bulbRow(t)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(width: 330, height: 176)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.black.opacity(0.55)))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(gold, lineWidth: 3))
        .scaleEffect(keys(pop, [(0, 0.55), (0.6, 1.06), (1, 1)]))
        .opacity(keys(pop, [(0, 0), (0.6, 1)]))
        .position(x: 195, y: 208)
    }

    private func bulbRow(_ t: Double) -> some View {
        HStack(spacing: 0) {
            ForEach(0..<12, id: \.self) { i in
                Circle()
                    .fill(introColor(0xFFD76A))
                    .frame(width: 9, height: 9)
                    .shadow(color: introColor(0xFFD76A), radius: 4)
                    .opacity(bulb(t, odd: i % 2 == 1))
                if i < 11 { Spacer(minLength: 0) }
            }
        }
        .opacity(prog(t, 1.08, 0.2))
    }

    private func bulb(_ t: Double, odd: Bool) -> Double {
        let phase = (t - (odd ? 1.325 : 1.1)) / 0.45
        guard phase > 0 else { return 0.25 }
        let c = phase.truncatingRemainder(dividingBy: 2)
        let x = c < 1 ? c : 2 - c
        return 0.25 + 0.75 * easeInOut(x)
    }

    private struct CardSpec { let rank: String; let suit: String; let isRed: Bool
        let delay: Double; let from: (Double, Double, Double); let to: (Double, Double, Double) }

    private var cardSpecs: [CardSpec] {[
        CardSpec(rank: "A", suit: "♠", isRed: false, delay: 1.3, from: (-220, 320, -120), to: (-72, 14, -14)),
        CardSpec(rank: "K", suit: "♥", isRed: true, delay: 1.45, from: (0, 380, 90), to: (0, 0, 0)),
        CardSpec(rank: "Q", suit: "♦", isRed: true, delay: 1.6, from: (220, 320, 120), to: (72, 14, 14))
    ]}

    private func cards(_ t: Double) -> some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                let c = cardSpecs[i]
                let raw = prog(t, c.delay, 0.45)
                let p = easeOutBack(raw, overshoot: 0.9)
                VStack(alignment: .leading, spacing: 0) {
                    Text(c.rank).font(.system(size: 18, weight: .heavy))
                    Text(c.suit).font(.system(size: 48))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .foregroundStyle(c.isRed ? introColor(0xC41F35) : introColor(0x151515))
                .padding(.vertical, 8).padding(.horizontal, 10)
                .frame(width: 92, height: 130)
                .background(RoundedRectangle(cornerRadius: 10).fill(paper)
                    .shadow(color: .black.opacity(0.5), radius: 12, y: 10))
                .rotationEffect(.degrees(lerp(c.from.2, c.to.2, p)), anchor: .bottom)
                .offset(x: lerp(c.from.0, c.to.0, p), y: lerp(c.from.1, c.to.1, p))
                .opacity(min(1, easeOut(raw) * 1.4))
            }
        }
        .position(x: 195, y: 395)
    }

    private func chips(_ t: Double) -> some View {
        let left: [(Color, Color, Double)] = [(introColor(0xC8243A), paper, 2.25),
                                              (introColor(0x1E5BB8), paper, 2.4),
                                              (introColor(0xC8243A), paper, 2.55)]
        let right: [(Color, Color, Double)] = [(introColor(0x1B1B1B), gold, 2.32),
                                               (introColor(0x1B1B1B), gold, 2.47),
                                               (introColor(0x1E5BB8), paper, 2.62)]
        return ZStack {
            ForEach(0..<3, id: \.self) { i in
                chip(t, left[i], level: i).position(x: 47, y: 480 - Double(i) * 10)
                chip(t, right[i], level: i).position(x: 343, y: 480 - Double(i) * 10)
            }
        }
    }

    private func chip(_ t: Double, _ spec: (Color, Color, Double), level: Int) -> some View {
        let p = prog(t, spec.2, 0.55)
        let y: Double
        if p < 0.7 { let x = p / 0.7; y = -520 * (1 - x * x) }
        else if p < 0.82 { y = -12 * easeOut((p - 0.7) / 0.12) }
        else { y = -12 * (1 - easeInOut((p - 0.82) / 0.18)) }
        return Ellipse()
            .fill(spec.0)
            .overlay(Ellipse().strokeBorder(spec.1, style: StrokeStyle(lineWidth: 3, dash: [6, 4])))
            .frame(width: 62, height: 20)
            .offset(y: y)
            .opacity(keys(p, [(0, 0), (0.1, 1)]))
    }

    private static let reelSymbols: [[String]] = [
        ["$", "♣", "BAR", "♦", "7", "♠", "$", "BAR", "♥", "7"],
        ["♥", "BAR", "7", "$", "♣", "♦", "BAR", "♠", "$", "7"],
        ["BAR", "♠", "$", "♥", "7", "BAR", "♦", "♣", "♠", "7"]
    ]
    private static let reelDurations: [Double] = [1.136, 1.364, 1.59]

    private func slotMachine(_ t: Double) -> some View {
        let rise = easeOut(prog(t, 1.8, 0.4))
        let win = easeOut(prog(t, 3.4, 0.9))
        let ring = keys(win, [(0, 0), (0.3, 6), (1, 2)])
        let ringAlpha = keys(win, [(0, 0), (0.3, 0.9), (1, 0.6)])
        let glow = keys(win, [(0, 0), (0.3, 25), (1, 12)])

        return HStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { r in reel(t, r) }
        }
        .overlay(
            Rectangle().fill(red).frame(height: 3)
                .shadow(color: red, radius: 5)
                .padding(.horizontal, -6)
                .opacity(prog(t, 3.4, 0.2))
        )
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(gold.opacity(ringAlpha), lineWidth: ring)
                .padding(-ring / 2)
                .shadow(color: gold.opacity(ringAlpha * 0.8), radius: glow)
        )
        .padding(14)
        .frame(width: 276)
        .background(RoundedRectangle(cornerRadius: 18).fill(introColor(0x2A0D12)))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(gold, lineWidth: 3))
        .opacity(rise)
        .offset(y: 18 * (1 - rise))
        .position(x: 195, y: 601)
    }

    private func reel(_ t: Double, _ r: Int) -> some View {
        let p = prog(t, 2.0, Self.reelDurations[r])
        let y = p < 0.88
            ? -806 * easeOut(p / 0.88)
            : -806 + 14 * easeInOut((p - 0.88) / 0.12)
        let blur = keys(p, [(0, 0), (0.12, 2.5), (0.7, 1.5), (0.86, 0), (1, 0)])
        return VStack(spacing: 0) {
            ForEach(Array(Self.reelSymbols[r].enumerated()), id: \.offset) { _, s in
                Text(s)
                    .font(.system(size: s == "7" ? 40 : (s == "BAR" ? 22 : 36), weight: .heavy))
                    .foregroundStyle(["7", "♥", "♦"].contains(s) ? red : introColor(0x151515))
                    .frame(width: 72, height: 88)
            }
        }
        .offset(y: y)
        .blur(radius: blur)
        .frame(width: 72, height: 88, alignment: .top)
        .background(paper)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private static let coinSpecs: [(Double, Double)] = [
        (12, 3.45), (70, 3.62), (130, 3.5), (188, 3.75), (246, 3.48), (300, 3.68), (352, 3.55),
        (40, 3.9), (100, 4.05), (160, 3.85), (218, 4.1), (276, 3.95), (330, 4.15), (200, 4.25)
    ]

    private func coins(_ t: Double) -> some View {
        ZStack {
            ForEach(0..<Self.coinSpecs.count, id: \.self) { i in
                let x = Self.coinSpecs[i].0
                let delay = Self.coinSpecs[i].1
                let p = prog(t, delay, 1.7)
                Circle()
                    .fill(gold)
                    .overlay(Circle().strokeBorder(introColor(0xB8862A), lineWidth: 2))
                    .frame(width: 22, height: 22)
                    .rotation3DEffect(.degrees(900 * p), axis: (x: 0, y: 1, z: 0))
                    .opacity(t < delay ? 0 : keys(p, [(0, 0), (0.08, 1)]))
                    .position(x: x + 11, y: -29 + lerp(-60, 940, p))
            }
        }
        .allowsHitTesting(false)
    }

    private func ending(_ t: Double) -> some View {
        let title = easeOut(prog(t, 3.7, 0.5))
        let cta = easeOut(prog(t, 3.95, 0.5))
        return ZStack {
            Text("Feeling lucky?")
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(cream)
                .opacity(title)
                .offset(y: 18 * (1 - title))
                .position(x: 195, y: 707)

            HStack(spacing: 12) {
                Button(action: enter) {
                    Text("Enter casino")
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundStyle(introColor(0x1A1406))
                        .frame(minWidth: 170, minHeight: 52)
                        .background(RoundedRectangle(cornerRadius: 14).fill(gold))
                }
                Button(action: restart) {
                    Text("Replay")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(gold)
                        .frame(minWidth: 110, minHeight: 52)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(gold, lineWidth: 2))
                }
            }
            .buttonStyle(.plain)
            .opacity(cta)
            .offset(y: 18 * (1 - cta))
            .allowsHitTesting(cta > 0.5)
            .position(x: 195, y: 774)
        }
    }

    // MARK: Actions

    private func restart() {
        startDate = Date().addingTimeInterval(Self.audioDelay)
        skipOffset = 0
        skipped = false
        if playSound { audio.play(delay: Self.audioDelay) }
        if reduceMotion { skip() }
    }

    private func skip() {
        let elapsed = Date().timeIntervalSince(startDate)
        skipOffset = max(0, Self.endTime - elapsed)
        skipped = true
        audio.silenceEffects()
    }

    private func enter() {
        audio.stop()
        onEnter()
    }
}

// MARK: - Helpers

private struct BeamShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.width * 0.45, y: 0))
        p.addLine(to: CGPoint(x: rect.width * 0.55, y: 0))
        p.addLine(to: CGPoint(x: rect.width, y: rect.height))
        p.addLine(to: CGPoint(x: 0, y: rect.height))
        p.closeSubpath()
        return p
    }
}

fileprivate func introColor(_ hex: UInt32) -> Color {
    Color(red: Double((hex >> 16) & 0xFF) / 255,
          green: Double((hex >> 8) & 0xFF) / 255,
          blue: Double(hex & 0xFF) / 255)
}

/// 0...1 progress of an animation that starts at `start` and lasts `duration`.
fileprivate func prog(_ t: Double, _ start: Double, _ duration: Double) -> Double {
    min(max((t - start) / duration, 0), 1)
}

fileprivate func lerp(_ a: Double, _ b: Double, _ x: Double) -> Double { a + (b - a) * x }
fileprivate func easeOut(_ x: Double) -> Double { 1 - pow(1 - x, 3) }
fileprivate func easeInOut(_ x: Double) -> Double { x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2 }
fileprivate func easeOutBack(_ x: Double, overshoot c1: Double = 1.70158) -> Double {
    let c3 = c1 + 1
    return 1 + c3 * pow(x - 1, 3) + c1 * pow(x - 1, 2)
}

/// Linear interpolation through (position, value) keyframes, like a CSS @keyframes rule.
fileprivate func keys(_ x: Double, _ frames: [(Double, Double)]) -> Double {
    guard let first = frames.first, let last = frames.last else { return 0 }
    if x <= first.0 { return first.1 }
    if x >= last.0 { return last.1 }
    for i in 1..<frames.count where x <= frames[i].0 {
        let (a, b) = (frames[i - 1], frames[i])
        return lerp(a.1, b.1, (x - a.0) / (b.0 - a.0))
    }
    return last.1
}

/// Hosts the intro inside the Bank's navigation stack and pushes through to
/// the real casino once the player taps "Enter casino".
struct CasinoEntryView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var entered = false

    var body: some View {
        CasinoIntroView(onEnter: { entered = true })
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $entered) {
                CasinoView(viewModel: viewModel)
            }
    }
}

#Preview {
    CasinoIntroView()
}
