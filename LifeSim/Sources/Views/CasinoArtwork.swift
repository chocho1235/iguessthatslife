//
//  CasinoArtwork.swift
//  Just Life
//
//  Code-drawn artwork for the casino: the lobby tiles and a table screen for
//  Coin Flip, Blackjack, Roulette and High or Low dice. Pure SwiftUI shapes, no assets.
//
//  The screens are layouts only. They hold sample values and call closures
//  (onBack, onFlip, onHit ...) so your game logic can drive them.
//  If you'd rather use your existing PlayingCardView, swap it in for CasinoCardFace.
//

import SwiftUI

// MARK: - Theme

enum CasinoArt {
    static let gold = hex(0xF5C542)
    static let goldDark = hex(0xB8862A)
    static let goldDeep = hex(0x7A4F0B)
    static let goldRim = hex(0xD9A632)
    static let cream = hex(0xF4EFE2)
    static let muted = hex(0xC9C3B0)
    static let paper = hex(0xFBF8F0)
    static let cardRed = hex(0xC41F35)
    static let ink = hex(0x151515)
    static let ink2 = hex(0x1A1406)
    static let pocketRed = hex(0xC41F35)
    static let pocketBlack = hex(0x161616)
    static let pocketGreen = hex(0x1F8A4C)

    static func hex(_ v: UInt32) -> Color {
        Color(red: Double((v >> 16) & 0xFF) / 255, green: Double((v >> 8) & 0xFF) / 255, blue: Double(v & 0xFF) / 255)
    }

    /// Matches `ChipPicker.chips` — index 4 ("MAX") has no fixed value, so
    /// callers resolve it against the player's actual cash instead.
    static let chipValues = [10, 50, 100, 500]

    static func betAmount(chipIndex: Int, cash: Int) -> Int {
        guard chipValues.indices.contains(chipIndex) else { return max(0, cash) }
        return chipValues[chipIndex]
    }
}

enum CasinoGame: String, CaseIterable, Identifiable {
    case coinFlip, blackjack, roulette, dice
    var id: String { rawValue }
}

// MARK: - Shared pieces

/// Felt or velvet background with a soft spotlight.
struct CasinoBackground: View {
    var colors: [Color]
    var center = UnitPoint(x: 0.5, y: 0.3)
    var body: some View {
        RadialGradient(colors: colors, center: center, startRadius: 0, endRadius: 620)
            .ignoresSafeArea()
    }
}

struct CasinoTopBar: View {
    var title: String
    var balance: String
    var onBack: () -> Void
    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(CasinoArt.cream)
                    .frame(width: 44, height: 44)
                    .background(RoundedRectangle(cornerRadius: 12).fill(.black.opacity(0.35)))
            }
            .accessibilityLabel("Back")
            Spacer()
            Text(title).font(.system(size: 18, weight: .heavy)).foregroundStyle(CasinoArt.cream)
            Spacer()
            BalancePill(balance: balance)
        }
        .frame(height: 48)
    }
}

struct BalancePill: View {
    var balance: String
    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(CasinoArt.gold)
                .overlay(Circle().strokeBorder(CasinoArt.goldDark, lineWidth: 2))
                .frame(width: 14, height: 14)
            Text(balance).font(.system(size: 14, weight: .semibold)).foregroundStyle(CasinoArt.cream)
        }
        .padding(.horizontal, 12)
        .frame(height: 34)
        .background(Capsule().fill(.black.opacity(0.45)))
        .overlay(Capsule().stroke(CasinoArt.gold.opacity(0.5), lineWidth: 1))
    }
}

struct GoldButton: View {
    var title: String
    var filled = true
    var height: CGFloat = 58
    var action: () -> Void = {}
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: filled ? .heavy : .semibold))
                .foregroundStyle(filled ? CasinoArt.ink2 : CasinoArt.cream)
                .frame(maxWidth: .infinity, minHeight: height)
                .background(RoundedRectangle(cornerRadius: 16).fill(filled ? CasinoArt.gold : .black.opacity(0.3)))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(filled ? .clear : CasinoArt.gold.opacity(0.6), lineWidth: 2))
        }
        .buttonStyle(.plain)
    }
}

/// A casino chip seen from above.
struct ChipView: View {
    var label: String = ""
    var fill: Color
    var edge: Color = CasinoArt.paper
    var size: CGFloat = 56
    var selected = false
    var body: some View {
        Circle()
            .fill(fill)
            .overlay(Circle().strokeBorder(edge, style: StrokeStyle(lineWidth: size * 0.07, dash: [size * 0.11, size * 0.07])))
            .overlay(Text(label).font(.system(size: size * 0.23, weight: .heavy)).foregroundStyle(.white))
            .frame(width: size, height: size)
            .overlay(Circle().stroke(selected ? CasinoArt.gold : .clear, lineWidth: 3).padding(-3))
            .shadow(color: .black.opacity(0.45), radius: selected ? 8 : 5, y: selected ? 8 : 4)
            .offset(y: selected ? -6 : 0)
    }
}

/// A chip seen from the side, for stacks.
struct ChipSideView: View {
    var fill: Color
    var edge: Color = CasinoArt.paper
    var width: CGFloat = 62
    var body: some View {
        Ellipse()
            .fill(fill)
            .overlay(Ellipse().strokeBorder(edge, style: StrokeStyle(lineWidth: 3, dash: [6, 4])))
            .frame(width: width, height: width * 0.32)
    }
}

struct ChipPicker: View {
    @Binding var selected: Int
    var showMax = true
    var size: CGFloat = 56
    static let chips: [(String, Color, Color)] = [
        ("10", CasinoArt.hex(0x1E5BB8), CasinoArt.paper),
        ("50", CasinoArt.hex(0xC8243A), CasinoArt.paper),
        ("100", CasinoArt.hex(0x1B1B1B), CasinoArt.gold),
        ("500", CasinoArt.hex(0x6B2FB3), CasinoArt.paper),
        ("MAX", CasinoArt.goldDark, CasinoArt.hex(0xFFF0B8))
    ]
    var body: some View {
        let list = showMax ? Self.chips : Array(Self.chips.prefix(4))
        HStack {
            ForEach(list.indices, id: \.self) { i in
                Button { selected = i } label: {
                    ChipView(label: list[i].0, fill: list[i].1, edge: list[i].2, size: size, selected: selected == i)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Bet \(list[i].0)")
                if i < list.count - 1 { Spacer(minLength: 0) }
            }
        }
    }
}

struct GoldCoin: View {
    var size: CGFloat
    var text = "JL"
    var caption: String? = nil
    var body: some View {
        ZStack {
            Circle().fill(RadialGradient(colors: [CasinoArt.hex(0xFFF0B8), CasinoArt.gold, CasinoArt.goldDark],
                                         center: UnitPoint(x: 0.35, y: 0.3), startRadius: 0, endRadius: size * 0.7))
            Circle().strokeBorder(CasinoArt.goldRim, lineWidth: size * 0.04)
            Circle().strokeBorder(CasinoArt.goldDeep.opacity(0.55), style: StrokeStyle(lineWidth: max(2, size * 0.015), dash: [size * 0.04, size * 0.03]))
                .padding(size * 0.1)
            VStack(spacing: 2) {
                Text(text).font(.system(size: size * 0.3, weight: .heavy)).foregroundStyle(CasinoArt.goldDeep)
                if let caption {
                    Text(caption).font(.system(size: size * 0.055, weight: .heavy)).tracking(size * 0.016)
                        .foregroundStyle(CasinoArt.goldDeep)
                }
            }
        }
        .frame(width: size, height: size)
        .overlay(Circle().stroke(CasinoArt.hex(0x8A5D14), lineWidth: max(1, size * 0.014)))
        .shadow(color: .black.opacity(0.55), radius: size * 0.09, y: size * 0.08)
    }
}

struct CasinoCardFace: View {
    var rank: String
    var suit: String
    var width: CGFloat = 84
    var isRed: Bool { suit == "♥" || suit == "♦" }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(rank).font(.system(size: width * 0.21, weight: .heavy))
            Text(suit).font(.system(size: width * 0.52))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .foregroundStyle(isRed ? CasinoArt.cardRed : CasinoArt.ink)
        .padding(width * 0.1)
        .frame(width: width, height: width * 1.43)
        .background(RoundedRectangle(cornerRadius: width * 0.12).fill(CasinoArt.paper))
        .shadow(color: .black.opacity(0.45), radius: 9, y: 8)
    }
}

struct CasinoCardBack: View {
    var width: CGFloat = 84
    var body: some View {
        RoundedRectangle(cornerRadius: width * 0.12)
            .fill(CasinoArt.hex(0xA3162B))
            .overlay(
                RoundedRectangle(cornerRadius: width * 0.07)
                    .strokeBorder(CasinoArt.paper, lineWidth: 2)
                    .background(Stripes().fill(CasinoArt.hex(0xC42A40)).clipShape(RoundedRectangle(cornerRadius: width * 0.07)))
                    .overlay(Circle().fill(CasinoArt.paper).frame(width: width * 0.4)
                        .overlay(Text("JL").font(.system(size: width * 0.15, weight: .heavy)).foregroundStyle(CasinoArt.hex(0xA3162B))))
                    .padding(width * 0.07)
            )
            .frame(width: width, height: width * 1.43)
            .shadow(color: .black.opacity(0.45), radius: 9, y: 8)
    }

    private struct Stripes: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            var x = -rect.height
            while x < rect.width {
                p.move(to: CGPoint(x: x, y: rect.height))
                p.addLine(to: CGPoint(x: x + 6, y: rect.height))
                p.addLine(to: CGPoint(x: x + 6 + rect.height, y: 0))
                p.addLine(to: CGPoint(x: x + rect.height, y: 0))
                p.closeSubpath()
                x += 12
            }
            return p
        }
    }
}

struct DieFace: View {
    var value: Int
    var size: CGFloat = 116
    var color: Color = CasinoArt.hex(0xC8243A)
    private var pips: [Int] {
        switch value {
        case 1: return [4]
        case 2: return [0, 8]
        case 3: return [0, 4, 8]
        case 4: return [0, 2, 6, 8]
        case 5: return [0, 2, 4, 6, 8]
        default: return [0, 2, 3, 5, 6, 8]
        }
    }
    var body: some View {
        let cell = (size - size * 0.28) / 3
        VStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { r in
                HStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { c in
                        Circle().fill(CasinoArt.paper)
                            .frame(width: size * 0.155, height: size * 0.155)
                            .opacity(pips.contains(r * 3 + c) ? 1 : 0)
                            .frame(width: cell, height: cell)
                    }
                }
            }
        }
        .frame(width: size, height: size)
        .background(
            RoundedRectangle(cornerRadius: size * 0.21).fill(color)
                .overlay(RoundedRectangle(cornerRadius: size * 0.21).stroke(.black.opacity(0.2), lineWidth: size * 0.04).blur(radius: 1).offset(y: size * 0.03).mask(RoundedRectangle(cornerRadius: size * 0.21)))
        )
        .shadow(color: .black.opacity(0.55), radius: size * 0.13, y: size * 0.13)
        .accessibilityLabel("Die showing \(value)")
    }
}

// MARK: - Roulette wheel

enum RouletteNumbers {
    static let wheelOrder = [0, 32, 15, 19, 4, 21, 2, 25, 17, 34, 6, 27, 13, 36, 11, 30, 8, 23, 10,
                             5, 24, 16, 33, 1, 20, 14, 31, 9, 22, 18, 29, 7, 28, 12, 35, 3, 26]
    static let reds: Set<Int> = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36]
    static func color(_ n: Int) -> Color {
        n == 0 ? CasinoArt.pocketGreen : (reds.contains(n) ? CasinoArt.pocketRed : CasinoArt.pocketBlack)
    }
}

struct RouletteWheel: View {
    var size: CGFloat = 250
    var showNumbers = true
    /// Number the ball sits in, or nil for no ball.
    var ball: Int? = 17
    var body: some View {
        let ring = size - size * 0.112
        let step = 360.0 / 37.0
        ZStack {
            Circle().fill(RadialGradient(colors: [CasinoArt.hex(0x8A4A24), CasinoArt.hex(0x5A2D14), CasinoArt.hex(0x3A1D0E)],
                                         center: UnitPoint(x: 0.4, y: 0.35), startRadius: 0, endRadius: size * 0.6))
                .overlay(Circle().stroke(CasinoArt.goldRim, lineWidth: 3))
            Canvas { ctx, sz in
                let c = CGPoint(x: sz.width / 2, y: sz.height / 2)
                let r = sz.width / 2
                for (i, n) in RouletteNumbers.wheelOrder.enumerated() {
                    let mid = Double(i) * step - 90
                    var p = Path()
                    p.move(to: c)
                    p.addArc(center: c, radius: r, startAngle: .degrees(mid - step / 2), endAngle: .degrees(mid + step / 2), clockwise: false)
                    p.closeSubpath()
                    ctx.fill(p, with: .color(RouletteNumbers.color(n)))
                }
            }
            .frame(width: ring, height: ring)
            .overlay(Circle().stroke(CasinoArt.goldRim, lineWidth: 2))
            if showNumbers {
                ForEach(Array(RouletteNumbers.wheelOrder.enumerated()), id: \.offset) { i, n in
                    Text("\(n)")
                        .font(.system(size: size * 0.036, weight: .heavy))
                        .foregroundStyle(.white)
                        .offset(y: -ring / 2 + size * 0.04)
                        .rotationEffect(.degrees(Double(i) * step))
                }
            }
            Circle()
                .fill(RadialGradient(colors: [CasinoArt.hex(0x7A4524), CasinoArt.hex(0x3A1D0E)],
                                     center: UnitPoint(x: 0.4, y: 0.35), startRadius: 0, endRadius: size * 0.3))
                .overlay(Circle().strokeBorder(CasinoArt.goldRim, lineWidth: 3))
                .frame(width: size * 0.544, height: size * 0.544)
            Circle()
                .fill(RadialGradient(colors: [CasinoArt.hex(0xFFF0B8), CasinoArt.gold, CasinoArt.goldDark],
                                     center: UnitPoint(x: 0.35, y: 0.3), startRadius: 0, endRadius: size * 0.1))
                .overlay(Circle().stroke(CasinoArt.hex(0x8A5D14), lineWidth: 4))
                .frame(width: size * 0.176, height: size * 0.176)
            if let ball, let i = RouletteNumbers.wheelOrder.firstIndex(of: ball) {
                Circle().fill(RadialGradient(colors: [.white, CasinoArt.hex(0xD8D8D8)], center: UnitPoint(x: 0.35, y: 0.3), startRadius: 0, endRadius: 6))
                    .frame(width: size * 0.048, height: size * 0.048)
                    .shadow(color: .black.opacity(0.6), radius: 2, y: 2)
                    .offset(y: -size * 0.32)
                    .rotationEffect(.degrees(Double(i) * step))
            }
        }
        .frame(width: size, height: size)
        .shadow(color: .black.opacity(0.6), radius: 20, y: 16)
    }
}

// MARK: - Lobby

struct CasinoLobbyView: View {
    var balance = "$5,000"
    var onBack: () -> Void = {}
    var onSelect: (CasinoGame) -> Void = { _ in }

    var body: some View {
        ZStack {
            CasinoBackground(colors: [CasinoArt.hex(0x17603E), CasinoArt.hex(0x0B2D1E), CasinoArt.hex(0x050807)])
            ScrollView {
                VStack(spacing: 18) {
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left").font(.system(size: 18, weight: .bold))
                                .foregroundStyle(CasinoArt.cream)
                                .frame(width: 44, height: 44)
                                .background(RoundedRectangle(cornerRadius: 12).fill(.black.opacity(0.35)))
                        }
                        .accessibilityLabel("Back")
                        Spacer()
                        Text("JUST LIFE").font(.system(size: 13, weight: .heavy)).tracking(4).foregroundStyle(CasinoArt.cream)
                        Spacer()
                        BalancePill(balance: balance)
                    }
                    VStack(spacing: 6) {
                        Text("CASINO")
                            .font(.system(size: 44, weight: .black, design: .rounded)).tracking(4)
                            .foregroundStyle(CasinoArt.hex(0xFF3B6B))
                            .shadow(color: CasinoArt.hex(0xFF3B6B), radius: 3)
                            .shadow(color: CasinoArt.hex(0xFF3B6B), radius: 9)
                            .shadow(color: CasinoArt.hex(0xFF3B6B), radius: 19)
                        Text("Pick a table").font(.system(size: 14)).foregroundStyle(CasinoArt.muted)
                    }
                    .padding(.vertical, 4)
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible())], spacing: 14) {
                        LobbyTile(title: "Coin Flip", subtitle: "Double or nothing",
                                  base: CasinoArt.hex(0x0E1B30), glow: CasinoArt.hex(0x22406E)) { CoinTileArt() }
                            .onTapGesture { onSelect(.coinFlip) }
                        LobbyTile(title: "Blackjack", subtitle: "Beat the dealer to 21",
                                  base: CasinoArt.hex(0x0B2D1E), glow: CasinoArt.hex(0x1D7A4E)) { BlackjackTileArt() }
                            .onTapGesture { onSelect(.blackjack) }
                        LobbyTile(title: "Roulette", subtitle: "Red, black or a lucky number",
                                  base: CasinoArt.hex(0x2A0B10), glow: CasinoArt.hex(0x5A1420)) { RouletteWheel(size: 118, showNumbers: false, ball: 32) }
                            .onTapGesture { onSelect(.roulette) }
                        LobbyTile(title: "High or Low", subtitle: "Call the next dice roll",
                                  base: CasinoArt.hex(0x1B0D2E), glow: CasinoArt.hex(0x44206E)) { DiceTileArt() }
                            .onTapGesture { onSelect(.dice) }
                    }
                    Text("Bets use your Just Life bank balance")
                        .font(.system(size: 12)).foregroundStyle(CasinoArt.hex(0x8F8A7A))
                        .padding(.top, 8)
                }
                .padding(16)
            }
        }
    }
}

struct LobbyTile<Art: View>: View {
    var title: String
    var subtitle: String
    var base: Color
    var glow: Color
    @ViewBuilder var art: () -> Art
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack { art() }
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .background(RadialGradient(colors: [glow, base], center: UnitPoint(x: 0.5, y: 0.45), startRadius: 0, endRadius: 110))
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.system(size: 17, weight: .heavy)).foregroundStyle(CasinoArt.cream)
                Text(subtitle).font(.system(size: 12)).foregroundStyle(CasinoArt.muted).lineLimit(2)
            }
            .padding(.horizontal, 14).padding(.top, 12).padding(.bottom, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(base)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(CasinoArt.gold.opacity(0.55), lineWidth: 2))
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

private struct CoinTileArt: View {
    var body: some View {
        ZStack {
            Ellipse().fill(CasinoArt.goldDark)
                .overlay(Ellipse().strokeBorder(CasinoArt.goldRim, lineWidth: 3))
                .frame(width: 30, height: 62)
                .rotationEffect(.degrees(-24))
                .offset(x: -50, y: -14)
            GoldCoin(size: 96)
        }
    }
}

private struct BlackjackTileArt: View {
    var body: some View {
        ZStack {
            CasinoCardFace(rank: "A", suit: "♠", width: 58).rotationEffect(.degrees(-12)).offset(x: -20, y: -4)
            CasinoCardFace(rank: "K", suit: "♥", width: 58).rotationEffect(.degrees(10)).offset(x: 16, y: -8)
            ChipView(fill: CasinoArt.hex(0xC8243A), size: 40).offset(x: 50, y: 40)
        }
    }
}

private struct DiceTileArt: View {
    var body: some View {
        ZStack {
            DieFace(value: 5, size: 62).rotationEffect(.degrees(-14)).offset(x: -26, y: 6)
            DieFace(value: 3, size: 62).rotationEffect(.degrees(12)).offset(x: 30, y: -2)
        }
    }
}

// MARK: - Coin Flip

struct CoinFlipView: View {
    var balance = "$5,000"
    var cash = 0
    var lastFlips: [Bool] = []   // true = heads
    var resultText: String? = nil
    var onBack: () -> Void = {}
    var onFlip: (_ heads: Bool, _ chipIndex: Int) -> Void = { _, _ in }

    @State private var callHeads = true
    @State private var chip = 2

    private var betAmount: Int { CasinoArt.betAmount(chipIndex: chip, cash: cash) }

    var body: some View {
        ZStack {
            CasinoBackground(colors: [CasinoArt.hex(0x22406E), CasinoArt.hex(0x0E1B30), CasinoArt.hex(0x060B14)], center: UnitPoint(x: 0.5, y: 0.28))
            VStack(spacing: 0) {
                CasinoTopBar(title: "Coin Flip", balance: balance, onBack: onBack)
                ZStack {
                    Circle().trim(from: 0, to: 0.5).stroke(CasinoArt.gold.opacity(0.18), lineWidth: 2)
                        .frame(width: 290, height: 290).rotationEffect(.degrees(-110))
                    Circle().trim(from: 0, to: 0.5).stroke(CasinoArt.gold.opacity(0.3), lineWidth: 2)
                        .frame(width: 256, height: 256).rotationEffect(.degrees(70))
                    Ellipse().fill(.black.opacity(0.45)).frame(width: 170, height: 22).blur(radius: 6).offset(y: 132)
                    GoldCoin(size: 210, caption: "HEADS")
                }
                .frame(height: 280)

                if let resultText {
                    Text(resultText)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(CasinoArt.cream)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 8)
                        .transition(.opacity)
                }

                Text("Call it").font(.system(size: 22, weight: .heavy)).foregroundStyle(CasinoArt.cream)
                    .padding(.bottom, 12)
                HStack(spacing: 12) {
                    callButton("Heads", symbol: "JL", selected: callHeads) { callHeads = true }
                    callButton("Tails", symbol: "★", selected: !callHeads) { callHeads = false }
                }

                VStack(spacing: 10) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Your bet").font(.system(size: 13)).foregroundStyle(CasinoArt.muted)
                        Spacer()
                        Text("$\(betAmount)").font(.system(size: 22, weight: .heavy)).foregroundStyle(CasinoArt.gold)
                    }
                    ChipPicker(selected: $chip)
                }
                .padding(.top, 22)

                GoldButton(title: "Flip for $\(betAmount)") { onFlip(callHeads, chip) }
                    .padding(.top, 20)
                    .disabled(cash <= 0)
                    .opacity(cash <= 0 ? 0.5 : 1)
                Spacer(minLength: 12)
                HStack {
                    Text("Last flips").font(.system(size: 13)).foregroundStyle(CasinoArt.muted)
                    Spacer()
                    HStack(spacing: 8) {
                        ForEach(lastFlips.indices, id: \.self) { i in
                            let h = lastFlips[i]
                            Text(h ? "H" : "T").font(.system(size: 11, weight: .heavy))
                                .foregroundStyle(h ? CasinoArt.goldDeep : CasinoArt.gold)
                                .frame(width: 28, height: 28)
                                .background(Circle().fill(h ? CasinoArt.gold : .clear))
                                .overlay(Circle().strokeBorder(CasinoArt.goldRim, lineWidth: 2))
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }

    private func callButton(_ title: String, symbol: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(symbol).font(.system(size: 10, weight: .heavy))
                    .frame(width: 26, height: 26)
                    .overlay(Circle().strokeBorder(selected ? CasinoArt.goldDeep : CasinoArt.gold, lineWidth: 3))
                    .foregroundStyle(selected ? CasinoArt.goldDeep : CasinoArt.gold)
                Text(title).font(.system(size: 18, weight: selected ? .heavy : .semibold))
            }
            .foregroundStyle(selected ? CasinoArt.ink2 : CasinoArt.cream)
            .frame(maxWidth: .infinity, minHeight: 64)
            .background(RoundedRectangle(cornerRadius: 16).fill(selected ? CasinoArt.gold : .black.opacity(0.3)))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(selected ? .clear : CasinoArt.gold.opacity(0.6), lineWidth: 2))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Blackjack

struct BlackjackTableView: View {
    enum Phase { case betting, playerTurn, dealerTurn, roundOver }
    struct Card: Hashable { var rank: String; var suit: String }

    var balance = "$4,900"
    var cash = 0
    var phase: Phase = .betting
    var handLabelSuffix: String? = nil   // e.g. "Hand 1 of 2" while split
    var dealer: [Card] = [Card(rank: "K", suit: "♥")]
    var dealerHidden = true
    var player: [Card] = [Card(rank: "7", suit: "♣"), Card(rank: "9", suit: "♦"), Card(rank: "4", suit: "♥")]
    var dealerTotal = "10"
    var playerTotal = "20"
    var bet = "$100"
    var canDouble = false
    var canSplit = false
    var resultText: String? = nil
    var onBack: () -> Void = {}
    var onDeal: (_ chipIndex: Int) -> Void = { _ in }
    var onHit: () -> Void = {}
    var onStand: () -> Void = {}
    var onDouble: () -> Void = {}
    var onSplit: () -> Void = {}
    var onNewRound: () -> Void = {}

    @State private var chip = 2
    private var betAmount: Int { CasinoArt.betAmount(chipIndex: chip, cash: cash) }

    var body: some View {
        ZStack {
            CasinoBackground(colors: [CasinoArt.hex(0x1D7A4E), CasinoArt.hex(0x0F4A30), CasinoArt.hex(0x062014)], center: UnitPoint(x: 0.5, y: 0.48))
            VStack(spacing: 0) {
                CasinoTopBar(title: "Blackjack", balance: balance, onBack: onBack)

                VStack(spacing: 10) {
                    handLabel("DEALER", total: phase == .betting ? "" : dealerTotal, highlight: false)
                    HStack(spacing: -26) {
                        ForEach(Array(dealer.enumerated()), id: \.offset) { i, c in
                            CasinoCardFace(rank: c.rank, suit: c.suit).rotationEffect(.degrees(-4))
                        }
                        if dealerHidden { CasinoCardBack().rotationEffect(.degrees(4)) }
                    }
                }
                .padding(.top, 14)
                .opacity(phase == .betting ? 0.25 : 1)

                ZStack {
                    ArcText(text: "BLACKJACK PAYS 3 TO 2", radius: 260, size: 15, weight: .heavy,
                            tracking: 3, color: CasinoArt.gold)
                    ArcText(text: "DEALER MUST STAND ON 17 AND DRAW TO 16", radius: 230, size: 10, weight: .semibold,
                            tracking: 1.5, color: CasinoArt.cream.opacity(0.7))
                        .offset(y: 26)
                }
                .frame(height: 70)
                .padding(.top, 16)

                if phase == .betting {
                    VStack(spacing: 14) {
                        Text("Place your bet").font(.system(size: 16, weight: .heavy)).foregroundStyle(CasinoArt.cream)
                        ChipPicker(selected: $chip)
                        Text("$\(betAmount)").font(.system(size: 26, weight: .heavy)).foregroundStyle(CasinoArt.gold)
                    }
                } else {
                    VStack(spacing: 6) {
                        ZStack {
                            Circle().strokeBorder(CasinoArt.gold.opacity(0.7), style: StrokeStyle(lineWidth: 2, dash: [5, 4]))
                                .frame(width: 92, height: 92)
                            ZStack {
                                ChipSideView(fill: CasinoArt.hex(0x1B1B1B), edge: CasinoArt.gold, width: 54).offset(y: 8)
                                ChipSideView(fill: CasinoArt.hex(0xC8243A), width: 54)
                                ChipSideView(fill: CasinoArt.hex(0x1E5BB8), width: 54).offset(y: -8)
                            }
                        }
                        Text(bet).font(.system(size: 15, weight: .heavy)).foregroundStyle(CasinoArt.gold)
                    }

                    VStack(spacing: 10) {
                        HStack(spacing: -30) {
                            ForEach(Array(player.enumerated()), id: \.offset) { i, c in
                                let tilt = player.count > 1 ? (Double(i) - Double(player.count - 1) / 2) * 6 : 0
                                CasinoCardFace(rank: c.rank, suit: c.suit).rotationEffect(.degrees(tilt))
                            }
                        }
                        handLabel("YOU" + (handLabelSuffix.map { " · \($0)" } ?? ""), total: playerTotal, highlight: true)
                    }
                    .padding(.top, 14)
                }

                if let resultText {
                    Text(resultText)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(CasinoArt.cream)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                        .transition(.opacity)
                }

                Spacer(minLength: 12)

                switch phase {
                case .betting:
                    GoldButton(title: "Deal $\(betAmount)") { onDeal(chip) }
                        .disabled(cash <= 0)
                        .opacity(cash <= 0 ? 0.5 : 1)
                case .playerTurn:
                    HStack(spacing: 10) {
                        actionButton("Hit", filled: true, action: onHit)
                        actionButton("Stand", action: onStand)
                        actionButton("Double", action: onDouble).disabled(!canDouble).opacity(canDouble ? 1 : 0.4)
                        actionButton("Split", action: onSplit).disabled(!canSplit).opacity(canSplit ? 1 : 0.4)
                    }
                case .dealerTurn:
                    Text("Dealer is playing…")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(CasinoArt.muted)
                        .frame(maxWidth: .infinity, minHeight: 64)
                case .roundOver:
                    GoldButton(title: "New Round", action: onNewRound)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }

    private func handLabel(_ name: String, total: String, highlight: Bool) -> some View {
        HStack(spacing: 8) {
            Text(name).font(.system(size: 12, weight: .heavy)).tracking(2.9).foregroundStyle(CasinoArt.gold)
            Text(total).font(.system(size: 14, weight: .heavy))
                .foregroundStyle(highlight ? CasinoArt.ink2 : CasinoArt.cream)
                .padding(.horizontal, 8).frame(minWidth: 30, minHeight: 26)
                .background(Capsule().fill(highlight ? CasinoArt.gold : .black.opacity(0.5)))
        }
    }

    private func actionButton(_ title: String, filled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).font(.system(size: 15, weight: .heavy))
                .foregroundStyle(filled ? CasinoArt.ink2 : CasinoArt.cream)
                .frame(maxWidth: .infinity, minHeight: 64)
                .background(RoundedRectangle(cornerRadius: 16).fill(filled ? CasinoArt.gold : .black.opacity(0.35)))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(filled ? .clear : CasinoArt.gold, lineWidth: 2))
        }
        .buttonStyle(.plain)
    }
}

/// Text laid out along the bottom of a circle (a smile), like the print on a blackjack table.
struct ArcText: View {
    var text: String
    var radius: CGFloat
    var size: CGFloat
    var weight: Font.Weight = .regular
    var tracking: CGFloat = 0
    var color: Color = .white
    var body: some View {
        let chars = Array(text)
        let charWidth = size * 0.68 + tracking
        let step = Double(charWidth / radius) * 180 / .pi
        let start = -step * Double(chars.count - 1) / 2
        ZStack {
            ForEach(chars.indices, id: \.self) { i in
                Text(String(chars[i]))
                    .font(.system(size: size, weight: weight))
                    .foregroundStyle(color)
                    .offset(y: radius)
                    .rotationEffect(.degrees(-(start + step * Double(i))))
            }
        }
        .offset(y: -radius)
        .accessibilityElement()
        .accessibilityLabel(text)
    }
}

// MARK: - Roulette

struct RouletteView: View {
    var balance = "$4,850"
    var cash = 0
    var lastNumbers: [Int] = []
    var ball: Int? = nil
    var resultText: String? = nil
    var onBack: () -> Void = {}
    var onSpin: (_ bets: [RouletteBetKind: Int]) -> Void = { _ in }

    @State private var chip = 1
    @State private var bets: [RouletteBetKind: Int] = [:]

    private var totalBet: Int { bets.values.reduce(0, +) }

    var body: some View {
        ZStack {
            CasinoBackground(colors: [CasinoArt.hex(0x5A1420), CasinoArt.hex(0x2A0B10), CasinoArt.hex(0x0C0406)], center: UnitPoint(x: 0.5, y: 0.22))
            ScrollView {
                VStack(spacing: 0) {
                    CasinoTopBar(title: "Roulette", balance: balance, onBack: onBack)
                    RouletteWheel(size: 220, ball: ball).padding(.top, 10)

                    if let resultText {
                        Text(resultText)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(CasinoArt.cream)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                    }

                    if !lastNumbers.isEmpty {
                        HStack {
                            Text("Last numbers").font(.system(size: 13)).foregroundStyle(CasinoArt.muted)
                            Spacer()
                            HStack(spacing: 6) {
                                ForEach(Array(lastNumbers.prefix(5).enumerated()), id: \.offset) { _, n in
                                    Text("\(n)").font(.system(size: 12, weight: .heavy)).foregroundStyle(.white)
                                        .frame(width: 30, height: 30)
                                        .background(Circle().fill(RouletteNumbers.color(n)))
                                        .overlay(Circle().strokeBorder(CasinoArt.gold.opacity(0.6), lineWidth: 2))
                                }
                            }
                        }
                        .padding(.top, 14)
                    }

                    bettingTable.padding(.top, 14)

                    HStack {
                        ChipPicker(selected: $chip, showMax: false, size: 42).frame(width: 190)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Total bet").font(.system(size: 12)).foregroundStyle(CasinoArt.muted)
                            Text("$\(totalBet)").font(.system(size: 20, weight: .heavy)).foregroundStyle(CasinoArt.gold)
                        }
                    }
                    .padding(.top, 14)

                    HStack(spacing: 10) {
                        Button("Clear") { bets.removeAll() }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(CasinoArt.cream)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(RoundedRectangle(cornerRadius: 12).fill(.black.opacity(0.3)))
                            .disabled(bets.isEmpty)
                            .opacity(bets.isEmpty ? 0.4 : 1)
                        GoldButton(title: "Spin", height: 44) {
                            let placed = bets
                            bets.removeAll()
                            onSpin(placed)
                        }
                        .disabled(totalBet <= 0 || totalBet > cash)
                        .opacity(totalBet <= 0 || totalBet > cash ? 0.5 : 1)
                    }
                    .padding(.top, 12)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
    }

    private var line: Color { .white.opacity(0.4) }
    private var chipValue: Int { CasinoArt.chipValues[safeIndex: chip] ?? cash }

    private func toggle(_ kind: RouletteBetKind) {
        if bets[kind] != nil {
            bets[kind] = nil
        } else {
            bets[kind] = chipValue
        }
    }

    private var bettingTable: some View {
        VStack(spacing: 4) {
            HStack(spacing: 0) {
                numberCell(0, height: 108)
                VStack(spacing: 0) {
                    ForEach([3, 2, 1], id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<12, id: \.self) { col in
                                numberCell(col * 3 + row, height: 36)
                            }
                        }
                    }
                }
            }
            HStack(spacing: 0) {
                Color.clear.frame(width: 30)
                outsideCell(Text("1st 12"), bet: .dozen(1))
                outsideCell(Text("2nd 12"), bet: .dozen(2))
                outsideCell(Text("3rd 12"), bet: .dozen(3))
            }
            .frame(height: 32)
            HStack(spacing: 0) {
                Color.clear.frame(width: 30)
                outsideCell(Text("1-18"), bet: .low)
                outsideCell(Text("EVEN"), bet: .even)
                outsideCell(ZStack {
                    Rectangle().fill(CasinoArt.pocketRed).frame(width: 14, height: 14).rotationEffect(.degrees(45))
                    if let amount = bets[.red] { ChipView(fill: CasinoArt.hex(0x1B1B1B), edge: CasinoArt.gold, size: 22).overlay(Text("\(amount)").font(.system(size: 8, weight: .heavy)).foregroundStyle(.white)) }
                }, bet: .red)
                outsideCell(ZStack {
                    Rectangle().fill(CasinoArt.pocketBlack).frame(width: 14, height: 14).rotationEffect(.degrees(45))
                    if let amount = bets[.black] { ChipView(fill: CasinoArt.hex(0x1B1B1B), edge: CasinoArt.gold, size: 22).overlay(Text("\(amount)").font(.system(size: 8, weight: .heavy)).foregroundStyle(.white)) }
                }, bet: .black)
                outsideCell(Text("ODD"), bet: .odd)
                outsideCell(Text("19-36"), bet: .high)
            }
            .frame(height: 34)
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 14).fill(CasinoArt.hex(0x0F5A36)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(CasinoArt.goldRim, lineWidth: 2))
    }

    @ViewBuilder
    private func numberCell(_ n: Int, height: CGFloat) -> some View {
        let cell = ZStack {
            RouletteNumbers.color(n)
            Text("\(n)").font(.system(size: 11, weight: .heavy)).foregroundStyle(.white)
            if let amount = bets[.number(n)] {
                ChipView(fill: CasinoArt.hex(0x1B1B1B), edge: CasinoArt.gold, size: n == 0 ? 24 : 22)
                    .overlay(Text("\(amount)").font(.system(size: 8, weight: .heavy)).foregroundStyle(.white))
            }
        }
        .overlay(Rectangle().stroke(line, lineWidth: 1))
        .contentShape(Rectangle())
        .onTapGesture { toggle(.number(n)) }

        if n == 0 {
            cell.frame(width: 30, height: height)
        } else {
            cell.frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
        }
    }

    private func outsideCell<C: View>(_ content: C, bet: RouletteBetKind) -> some View {
        content
            .font(.system(size: 10, weight: .heavy))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(Rectangle().stroke(line, lineWidth: 1))
            .contentShape(Rectangle())
            .onTapGesture { toggle(bet) }
    }
}

private extension Array {
    subscript(safeIndex index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - High or Low dice

struct HighLowDiceView: View {
    var balance = "$5,000"
    var cash = 0
    var dice = (5, 3)
    var resultText: String? = nil
    var onBack: () -> Void = {}
    var onRoll: (_ higher: Bool, _ chipIndex: Int) -> Void = { _, _ in }

    @State private var higher = true
    @State private var chip = 2

    private var betAmount: Int { CasinoArt.betAmount(chipIndex: chip, cash: cash) }

    var body: some View {
        ZStack {
            CasinoBackground(colors: [CasinoArt.hex(0x44206E), CasinoArt.hex(0x1B0D2E), CasinoArt.hex(0x07040D)], center: UnitPoint(x: 0.5, y: 0.28))
            VStack(spacing: 0) {
                CasinoTopBar(title: "High or Low", balance: balance, onBack: onBack)
                ZStack {
                    Ellipse().fill(.black.opacity(0.5)).frame(width: 260, height: 26).blur(radius: 8).offset(y: 92)
                    HStack(spacing: 26) {
                        DieFace(value: dice.0).rotationEffect(.degrees(-12))
                        DieFace(value: dice.1).rotationEffect(.degrees(10)).offset(y: -10)
                    }
                }
                .frame(height: 250)

                VStack(spacing: 6) {
                    Text("CURRENT ROLL").font(.system(size: 12, weight: .heavy)).tracking(2.9).foregroundStyle(CasinoArt.gold)
                    Text("\(dice.0 + dice.1)").font(.system(size: 30, weight: .heavy)).foregroundStyle(CasinoArt.cream)
                        .frame(width: 64, height: 64)
                        .background(Circle().fill(.black.opacity(0.4)))
                        .overlay(Circle().strokeBorder(CasinoArt.gold, lineWidth: 3))
                }

                if let resultText {
                    Text(resultText)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(CasinoArt.cream)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                        .transition(.opacity)
                }

                Text("Will the next roll be higher or lower?")
                    .font(.system(size: 20, weight: .heavy)).foregroundStyle(CasinoArt.cream)
                    .multilineTextAlignment(.center)
                    .padding(.top, 14).padding(.bottom, 12)
                HStack(spacing: 12) {
                    pickButton("Higher", icon: "arrow.up", selected: higher) { higher = true }
                    pickButton("Lower", icon: "arrow.down", selected: !higher) { higher = false }
                }

                VStack(spacing: 10) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Your bet").font(.system(size: 13)).foregroundStyle(CasinoArt.muted)
                        Spacer()
                        Text("$\(betAmount)").font(.system(size: 22, weight: .heavy)).foregroundStyle(CasinoArt.gold)
                    }
                    ChipPicker(selected: $chip)
                }
                .padding(.top, 20)
                Spacer(minLength: 12)
                GoldButton(title: "Roll for $\(betAmount)") { onRoll(higher, chip) }
                    .disabled(cash <= 0)
                    .opacity(cash <= 0 ? 0.5 : 1)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }

    private func pickButton(_ title: String, icon: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon).font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(selected ? CasinoArt.ink2 : CasinoArt.gold)
                Text(title).font(.system(size: 18, weight: selected ? .heavy : .semibold))
            }
            .foregroundStyle(selected ? CasinoArt.ink2 : CasinoArt.cream)
            .frame(maxWidth: .infinity, minHeight: 68)
            .background(RoundedRectangle(cornerRadius: 16).fill(selected ? CasinoArt.gold : .black.opacity(0.3)))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(selected ? .clear : CasinoArt.gold.opacity(0.6), lineWidth: 2))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Lobby") { CasinoLobbyView() }
#Preview("Coin Flip") { CoinFlipView() }
#Preview("Blackjack") { BlackjackTableView() }
#Preview("Roulette") { RouletteView() }
#Preview("High or Low") { HighLowDiceView() }
