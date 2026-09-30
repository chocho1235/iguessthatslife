import SwiftUI

private enum AvatarPalette {
    static let skinTones: [Color] = [
        Color(red: 1.00, green: 0.87, blue: 0.73),
        Color(red: 0.96, green: 0.76, blue: 0.58),
        Color(red: 0.87, green: 0.65, blue: 0.47),
        Color(red: 0.69, green: 0.47, blue: 0.32),
        Color(red: 0.47, green: 0.31, blue: 0.20),
    ]

    static let hairColors: [Color] = [
        Color(red: 0.12, green: 0.09, blue: 0.08),
        Color(red: 0.30, green: 0.19, blue: 0.12),
        Color(red: 0.52, green: 0.33, blue: 0.15),
        Color(red: 0.78, green: 0.62, blue: 0.30),
        Color(red: 0.62, green: 0.16, blue: 0.10),
        Color(red: 0.08, green: 0.08, blue: 0.09),
    ]

    static let grayHairColors: [Color] = [
        Color(white: 0.78),
        Color(white: 0.88),
        Color(red: 0.82, green: 0.80, blue: 0.78),
    ]

    static let outfitColors: [Color] = [
        Color(red: 0.20, green: 0.45, blue: 0.85),
        Color(red: 0.16, green: 0.60, blue: 0.55),
        Color(red: 0.55, green: 0.30, blue: 0.80),
        Color(red: 0.85, green: 0.35, blue: 0.55),
        Color(red: 0.90, green: 0.55, blue: 0.15),
        Color(red: 0.20, green: 0.65, blue: 0.40),
        Color(red: 0.30, green: 0.35, blue: 0.75),
    ]

    static let irisColors: [Color] = [
        Color(red: 0.36, green: 0.25, blue: 0.15),
        Color(red: 0.20, green: 0.45, blue: 0.65),
        Color(red: 0.25, green: 0.50, blue: 0.30),
        Color(red: 0.35, green: 0.35, blue: 0.38),
    ]
}

private func seedIndex(_ seed: String, salt: String, mod: Int) -> Int {
    var hash: UInt64 = 5381
    for byte in (seed + salt).utf8 {
        hash = ((hash << 5) &+ hash) &+ UInt64(byte)
    }
    return Int(hash % UInt64(mod))
}

private enum HairStyle {
    case tuft, short, long, grayShort, bun, bald
}

struct AvatarView: View {
    let seed: String
    let gender: Gender
    let stage: LifeStage
    var isAlive: Bool = true
    var equipped: [Accessory] = []
    var scars: Int = 0

    var body: some View {
        Canvas { context, size in
            let scale = size.width / 200
            drawBackground(&context, scale: scale)
            if isAlive {
                drawPerson(&context, scale: scale)
                for accessory in equipped {
                    drawAccessory(accessory, &context, scale: scale)
                }
            } else {
                drawTombstone(&context, scale: scale)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var skinTone: Color {
        AvatarPalette.skinTones[seedIndex(seed, salt: "skin", mod: AvatarPalette.skinTones.count)]
    }

    private var hairColor: Color {
        if stage == .senior {
            return AvatarPalette.grayHairColors[seedIndex(seed, salt: "hair", mod: AvatarPalette.grayHairColors.count)]
        }
        return AvatarPalette.hairColors[seedIndex(seed, salt: "hair", mod: AvatarPalette.hairColors.count)]
    }

    private var outfitColor: Color {
        AvatarPalette.outfitColors[seedIndex(seed, salt: "outfit", mod: AvatarPalette.outfitColors.count)]
    }

    private var irisColor: Color {
        AvatarPalette.irisColors[seedIndex(seed, salt: "eyes", mod: AvatarPalette.irisColors.count)]
    }

    private var hairStyle: HairStyle {
        if stage == .infant { return .tuft }
        if gender == .male {
            if stage == .senior {
                return seedIndex(seed, salt: "balding", mod: 100) < 45 ? .bald : .grayShort
            }
            if stage == .adult {
                return seedIndex(seed, salt: "balding", mod: 100) < 22 ? .bald : .short
            }
            return .short
        }
        return stage == .senior ? .bun : .long
    }

    private var wrinkleLineCount: Int {
        seedIndex(seed, salt: "wrinkles", mod: 3) + 1
    }

    private var hasFreckles: Bool {
        stage == .child && seedIndex(seed, salt: "freckles", mod: 100) < 30
    }

    private func pt(_ x: CGFloat, _ y: CGFloat, _ scale: CGFloat) -> CGPoint {
        CGPoint(x: x * scale, y: y * scale)
    }

    private func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ scale: CGFloat) -> CGRect {
        CGRect(x: x * scale, y: y * scale, width: w * scale, height: h * scale)
    }

    private func drawBackground(_ context: inout GraphicsContext, scale: CGFloat) {
        let tint = isAlive ? outfitColor : Color(white: 0.6)
        let gradient = Gradient(colors: [tint.opacity(0.30), tint.opacity(0.06)])
        context.fill(
            Path(ellipseIn: rect(0, 0, 200, 200, scale)),
            with: .radialGradient(gradient, center: pt(100, 90, scale), startRadius: 0, endRadius: 100 * scale)
        )
    }

    private func drawPerson(_ context: inout GraphicsContext, scale: CGFloat) {
        let headRect = rect(55, 35, 90, 100, scale)

        // Long hair back-drape, flowing past the shoulders
        if hairStyle == .long {
            context.fill(Path(roundedRect: rect(58, 55, 26, 120, scale), cornerRadius: 13 * scale), with: .color(hairColor))
            context.fill(Path(roundedRect: rect(116, 55, 26, 120, scale), cornerRadius: 13 * scale), with: .color(hairColor))
        }

        // Torso / shoulders
        context.fill(Path(roundedRect: rect(40, 150, 120, 90, scale), cornerRadius: 40 * scale), with: .color(outfitColor))
        context.fill(Path(roundedRect: rect(90, 148, 20, 16, scale), cornerRadius: 6 * scale), with: .color(skinTone))

        // Neck
        context.fill(Path(roundedRect: rect(85, 128, 30, 30, scale), cornerRadius: 8 * scale), with: .color(skinTone))

        // Ears
        context.fill(Path(ellipseIn: rect(48, 72, 15, 24, scale)), with: .color(skinTone))
        context.fill(Path(ellipseIn: rect(137, 72, 15, 24, scale)), with: .color(skinTone))

        // Hair cap — drawn behind the face so only the rim above/beside the head shows
        switch hairStyle {
        case .tuft:
            var tuft = Path()
            tuft.move(to: pt(92, 42, scale))
            tuft.addQuadCurve(to: pt(108, 42, scale), control: pt(100, 18, scale))
            tuft.addQuadCurve(to: pt(92, 42, scale), control: pt(100, 34, scale))
            context.fill(tuft, with: .color(hairColor))
        case .short, .grayShort:
            context.fill(Path(ellipseIn: rect(50, 22, 100, 80, scale)), with: .color(hairColor))
        case .long, .bun:
            context.fill(Path(ellipseIn: rect(48, 20, 104, 84, scale)), with: .color(hairColor))
        case .bald:
            break
        }

        // Face
        context.fill(Path(ellipseIn: headRect), with: .color(skinTone))

        // Bun sits on top-back of the head for the senior female style
        if hairStyle == .bun {
            context.fill(Path(ellipseIn: rect(88, 18, 24, 22, scale)), with: .color(hairColor))
        }

        // A little shine for a fully bald head
        if hairStyle == .bald {
            context.fill(Path(ellipseIn: rect(88, 30, 22, 12, scale)), with: .color(.white.opacity(0.18)))
        }

        if hasFreckles {
            drawFreckles(&context, scale: scale)
        }

        // Eyebrows
        context.fill(Path(roundedRect: rect(74, 76, 18, 5, scale), cornerRadius: 2.5 * scale), with: .color(hairColor.opacity(0.85)))
        context.fill(Path(roundedRect: rect(108, 76, 18, 5, scale), cornerRadius: 2.5 * scale), with: .color(hairColor.opacity(0.85)))

        // Eyes
        drawEye(&context, cx: 83, cy: 88, scale: scale)
        drawEye(&context, cx: 117, cy: 88, scale: scale)

        // Mouth
        var mouth = Path()
        mouth.move(to: pt(88, 114, scale))
        mouth.addQuadCurve(to: pt(112, 114, scale), control: pt(100, 124, scale))
        context.stroke(mouth, with: .color(.black.opacity(0.65)), lineWidth: 2.5 * scale)

        // Cheek blush for the youngest stages
        if stage == .infant || stage == .child {
            context.fill(Path(ellipseIn: rect(62, 100, 16, 10, scale)), with: .color(.pink.opacity(0.35)))
            context.fill(Path(ellipseIn: rect(122, 100, 16, 10, scale)), with: .color(.pink.opacity(0.35)))
        }

        // Glasses for seniors
        if stage == .senior {
            var glasses = Path()
            glasses.addEllipse(in: rect(70, 78, 24, 20, scale))
            glasses.addEllipse(in: rect(106, 78, 24, 20, scale))
            glasses.move(to: pt(94, 88, scale))
            glasses.addLine(to: pt(106, 88, scale))
            context.stroke(glasses, with: .color(.black.opacity(0.55)), lineWidth: 2 * scale)
        }

        if stage == .senior {
            drawWrinkles(&context, scale: scale)
        }
        if scars > 0 {
            drawScars(&context, scale: scale)
        }
    }

    private func drawFreckles(_ context: inout GraphicsContext, scale: CGFloat) {
        let dots: [(CGFloat, CGFloat)] = [(72, 98), (78, 103), (85, 100), (115, 100), (122, 103), (128, 98)]
        for (x, y) in dots {
            context.fill(Path(ellipseIn: rect(x, y, 2.5, 2.5, scale)), with: .color(Color(red: 0.55, green: 0.35, blue: 0.2).opacity(0.5)))
        }
    }

    private func drawWrinkles(_ context: inout GraphicsContext, scale: CGFloat) {
        let color = Color.black.opacity(0.22)
        for i in 0..<wrinkleLineCount {
            let y = 52 + CGFloat(i) * 6
            var line = Path()
            line.move(to: pt(72, y, scale))
            line.addQuadCurve(to: pt(128, y, scale), control: pt(100, y - 4, scale))
            context.stroke(line, with: .color(color), lineWidth: 1 * scale)
        }
        for (cx, sign) in [(CGFloat(70), CGFloat(-1)), (CGFloat(130), CGFloat(1))] {
            for i in 0..<2 {
                let yOff = CGFloat(i) * 4
                var line = Path()
                line.move(to: pt(cx, 86 + yOff, scale))
                line.addLine(to: pt(cx + 8 * sign, 84 + yOff, scale))
                context.stroke(line, with: .color(color), lineWidth: 1 * scale)
            }
        }
    }

    private func drawScars(_ context: inout GraphicsContext, scale: CGFloat) {
        let positions: [(x: CGFloat, y: CGFloat, dir: CGFloat)] = [
            (72, 96, 1), (128, 100, -1), (100, 68, 1),
        ]
        for i in 0..<min(scars, positions.count) {
            let spot = positions[i]
            var line = Path()
            line.move(to: pt(spot.x, spot.y, scale))
            line.addLine(to: pt(spot.x + 9 * spot.dir, spot.y + 13, scale))
            context.stroke(line, with: .color(Color(red: 0.55, green: 0.25, blue: 0.25).opacity(0.75)), lineWidth: 1.4 * scale)
        }
    }

    private func drawEye(_ context: inout GraphicsContext, cx: CGFloat, cy: CGFloat, scale: CGFloat) {
        context.fill(Path(ellipseIn: rect(cx - 8, cy - 6, 16, 12, scale)), with: .color(.white))
        context.fill(Path(ellipseIn: rect(cx - 4, cy - 4, 8, 8, scale)), with: .color(irisColor))
        context.fill(Path(ellipseIn: rect(cx - 2, cy - 2, 3.5, 3.5, scale)), with: .color(.black))
    }

    private func drawAccessory(_ accessory: Accessory, _ context: inout GraphicsContext, scale: CGFloat) {
        switch accessory.id {
        case "cap":
            context.fill(Path(ellipseIn: rect(56, 14, 88, 46, scale)), with: .color(accessory.color))
            context.fill(Path(roundedRect: rect(106, 46, 46, 14, scale), cornerRadius: 7 * scale), with: .color(accessory.color.opacity(0.85)))

        case "tophat":
            context.fill(Path(roundedRect: rect(62, 44, 76, 10, scale), cornerRadius: 5 * scale), with: .color(.black))
            context.fill(Path(roundedRect: rect(78, 4, 44, 42, scale), cornerRadius: 3 * scale), with: .color(.black))
            context.fill(Path(roundedRect: rect(78, 32, 44, 8, scale), cornerRadius: 2 * scale), with: .color(.red))

        case "beanie":
            context.fill(Path(ellipseIn: rect(56, 16, 88, 48, scale)), with: .color(accessory.color))
            context.fill(Path(roundedRect: rect(56, 50, 88, 12, scale), cornerRadius: 6 * scale), with: .color(accessory.color.opacity(0.7)))
            context.fill(Path(ellipseIn: rect(94, 4, 12, 12, scale)), with: .color(.white))

        case "sunglasses":
            var lenses = Path()
            lenses.addRoundedRect(in: rect(68, 80, 26, 18, scale), cornerSize: CGSize(width: 6 * scale, height: 6 * scale))
            lenses.addRoundedRect(in: rect(106, 80, 26, 18, scale), cornerSize: CGSize(width: 6 * scale, height: 6 * scale))
            context.fill(lenses, with: .color(.black.opacity(0.85)))
            var bridge = Path()
            bridge.move(to: pt(94, 88, scale))
            bridge.addLine(to: pt(106, 88, scale))
            context.stroke(bridge, with: .color(.black.opacity(0.85)), lineWidth: 2 * scale)

        case "roundglasses":
            var lenses = Path()
            lenses.addEllipse(in: rect(70, 78, 24, 20, scale))
            lenses.addEllipse(in: rect(106, 78, 24, 20, scale))
            context.stroke(lenses, with: .color(accessory.color), lineWidth: 3 * scale)
            var bridge = Path()
            bridge.move(to: pt(94, 88, scale))
            bridge.addLine(to: pt(106, 88, scale))
            context.stroke(bridge, with: .color(accessory.color), lineWidth: 3 * scale)

        case "readingglasses":
            var lenses = Path()
            lenses.addRoundedRect(in: rect(70, 80, 24, 17, scale), cornerSize: CGSize(width: 4 * scale, height: 4 * scale))
            lenses.addRoundedRect(in: rect(106, 80, 24, 17, scale), cornerSize: CGSize(width: 4 * scale, height: 4 * scale))
            context.stroke(lenses, with: .color(accessory.color), lineWidth: 2 * scale)
            var bridge = Path()
            bridge.move(to: pt(94, 88, scale))
            bridge.addLine(to: pt(106, 88, scale))
            context.stroke(bridge, with: .color(accessory.color), lineWidth: 2 * scale)

        case "squareglasses":
            var lenses = Path()
            lenses.addRect(rect(69, 78, 25, 21, scale))
            lenses.addRect(rect(106, 78, 25, 21, scale))
            context.stroke(lenses, with: .color(accessory.color), lineWidth: 3 * scale)
            var bridge = Path()
            bridge.move(to: pt(94, 88, scale))
            bridge.addLine(to: pt(106, 88, scale))
            context.stroke(bridge, with: .color(accessory.color), lineWidth: 3 * scale)

        case "cateyeglasses":
            for originX in [CGFloat(69), CGFloat(106)] {
                var lens = Path()
                lens.move(to: pt(originX, 92, scale))
                lens.addLine(to: pt(originX, 82, scale))
                lens.addQuadCurve(to: pt(originX + 25, 78, scale), control: pt(originX + 12, 74, scale))
                lens.addLine(to: pt(originX + 25, 90, scale))
                lens.addQuadCurve(to: pt(originX, 92, scale), control: pt(originX + 12, 96, scale))
                lens.closeSubpath()
                context.stroke(lens, with: .color(accessory.color), lineWidth: 2.5 * scale)
            }
            var bridge = Path()
            bridge.move(to: pt(94, 88, scale))
            bridge.addLine(to: pt(106, 88, scale))
            context.stroke(bridge, with: .color(accessory.color), lineWidth: 2.5 * scale)

        case "aviators":
            var lenses = Path()
            lenses.addPath(Path(ellipseIn: rect(68, 79, 26, 22, scale)))
            lenses.addPath(Path(ellipseIn: rect(106, 79, 26, 22, scale)))
            context.fill(lenses, with: .color(accessory.color.opacity(0.55)))
            context.stroke(lenses, with: .color(.black.opacity(0.7)), lineWidth: 1.5 * scale)
            var bridge = Path()
            bridge.move(to: pt(94, 88, scale))
            bridge.addLine(to: pt(106, 88, scale))
            context.stroke(bridge, with: .color(.black.opacity(0.7)), lineWidth: 1.5 * scale)

        case "eyepatch":
            context.fill(Path(roundedRect: rect(106, 78, 26, 20, scale), cornerRadius: 4 * scale), with: .color(.black))
            var strap = Path()
            strap.move(to: pt(119, 78, scale))
            strap.addLine(to: pt(58, 58, scale))
            context.stroke(strap, with: .color(.black), lineWidth: 2 * scale)

        case "necklace":
            var chain = Path()
            chain.addArc(center: pt(100, 150, scale), radius: 20 * scale, startAngle: .degrees(20), endAngle: .degrees(160), clockwise: false)
            context.stroke(chain, with: .color(accessory.color), lineWidth: 2.5 * scale)
            context.fill(Path(ellipseIn: rect(94, 166, 12, 12, scale)), with: .color(accessory.color))

        case "bowtie":
            var left = Path()
            left.move(to: pt(100, 150, scale))
            left.addLine(to: pt(82, 142, scale))
            left.addLine(to: pt(82, 158, scale))
            left.closeSubpath()
            var right = Path()
            right.move(to: pt(100, 150, scale))
            right.addLine(to: pt(118, 142, scale))
            right.addLine(to: pt(118, 158, scale))
            right.closeSubpath()
            context.fill(left, with: .color(accessory.color))
            context.fill(right, with: .color(accessory.color))
            context.fill(Path(ellipseIn: rect(95, 145, 10, 10, scale)), with: .color(accessory.color.opacity(0.8)))

        case "scarf":
            context.fill(Path(roundedRect: rect(82, 138, 36, 20, scale), cornerRadius: 10 * scale), with: .color(accessory.color))
            context.fill(Path(roundedRect: rect(92, 155, 18, 35, scale), cornerRadius: 6 * scale), with: .color(accessory.color.opacity(0.9)))

        default:
            break
        }
    }

    private func drawTombstone(_ context: inout GraphicsContext, scale: CGFloat) {
        context.fill(Path(ellipseIn: rect(20, 168, 160, 30, scale)), with: .color(Color(red: 0.55, green: 0.75, blue: 0.45)))

        var stone = Path()
        stone.move(to: pt(65, 190, scale))
        stone.addLine(to: pt(65, 100, scale))
        stone.addQuadCurve(to: pt(135, 100, scale), control: pt(100, 55, scale))
        stone.addLine(to: pt(135, 190, scale))
        stone.closeSubpath()
        context.fill(stone, with: .color(Color(white: 0.72)))
        context.stroke(stone, with: .color(Color(white: 0.55)), lineWidth: 2 * scale)

        context.fill(Path(roundedRect: rect(96, 138, 8, 30, scale), cornerRadius: 2 * scale), with: .color(Color(white: 0.55)))
        context.fill(Path(roundedRect: rect(86, 148, 28, 8, scale), cornerRadius: 2 * scale), with: .color(Color(white: 0.55)))

        context.draw(
            Text("R.I.P.")
                .font(.system(size: 16 * scale, weight: .bold, design: .serif))
                .foregroundColor(Color(white: 0.35)),
            at: pt(100, 122, scale)
        )
    }
}

#Preview {
    HStack(spacing: 16) {
        AvatarView(seed: "Ava Brown", gender: .female, stage: .child, equipped: [AccessoryData.byID["cap"]!])
        AvatarView(seed: "James Smith", gender: .male, stage: .adult, equipped: [AccessoryData.byID["sunglasses"]!, AccessoryData.byID["bowtie"]!])
        AvatarView(seed: "Riley Martin", gender: .female, stage: .senior, equipped: [AccessoryData.byID["necklace"]!])
        AvatarView(seed: "David Jones", gender: .male, stage: .senior, isAlive: false)
    }
    .padding()
}
