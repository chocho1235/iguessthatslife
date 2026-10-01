import SwiftUI
import UIKit

extension Color {
    /// Blends toward white/black in RGB space — simple, fast shading for
    /// procedurally-drawn art that avoids pulling in HSB conversions.
    func lighter(by amount: CGFloat) -> Color { mixed(toward: .white, amount: amount) }
    func darker(by amount: CGFloat) -> Color { mixed(toward: .black, amount: amount) }

    private func mixed(toward target: Color, amount: CGFloat) -> Color {
        let ui = UIColor(self)
        let targetUI = UIColor(target)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        ui.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        targetUI.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return Color(
            red: r1 + (r2 - r1) * amount,
            green: g1 + (g2 - g1) * amount,
            blue: b1 + (b2 - b1) * amount,
            opacity: a1
        )
    }
}

private enum AvatarPalette {
    static let skinTones: [Color] = [
        Color(red: 1.00, green: 0.91, blue: 0.80),
        Color(red: 1.00, green: 0.87, blue: 0.73),
        Color(red: 0.96, green: 0.80, blue: 0.64),
        Color(red: 0.96, green: 0.76, blue: 0.58),
        Color(red: 0.89, green: 0.69, blue: 0.50),
        Color(red: 0.87, green: 0.65, blue: 0.47),
        Color(red: 0.76, green: 0.54, blue: 0.36),
        Color(red: 0.69, green: 0.47, blue: 0.32),
        Color(red: 0.55, green: 0.38, blue: 0.25),
        Color(red: 0.47, green: 0.31, blue: 0.20),
        Color(red: 0.33, green: 0.22, blue: 0.15),
    ]

    static let hairColors: [Color] = [
        Color(red: 0.12, green: 0.09, blue: 0.08),
        Color(red: 0.30, green: 0.19, blue: 0.12),
        Color(red: 0.52, green: 0.33, blue: 0.15),
        Color(red: 0.78, green: 0.62, blue: 0.30),
        Color(red: 0.62, green: 0.16, blue: 0.10),
        Color(red: 0.08, green: 0.08, blue: 0.09),
        Color(red: 0.05, green: 0.05, blue: 0.05),
        Color(red: 0.40, green: 0.24, blue: 0.10),
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

    static let accentColors: [Color] = [
        Color(red: 1.00, green: 0.72, blue: 0.20),
        Color(red: 0.96, green: 0.32, blue: 0.38),
        Color(red: 0.12, green: 0.70, blue: 0.72),
        Color(red: 0.48, green: 0.35, blue: 0.86),
        Color(red: 0.95, green: 0.45, blue: 0.68),
    ]
}

private func seedIndex(_ seed: String, salt: String, mod: Int) -> Int {
    var hash: UInt64 = 5381
    for byte in (seed + salt).utf8 {
        hash = ((hash << 5) &+ hash) &+ UInt64(byte)
    }
    return Int(hash % UInt64(mod))
}

struct AvatarVisualIdentity {
    let skinTone: Color
    let hairColor: Color
    let outfitColor: Color
    let accentColor: Color

    init(seed: String, stage: LifeStage, region: CultureRegion) {
        let toneIndices = region.skinToneIndices
        skinTone = AvatarPalette.skinTones[toneIndices[seedIndex(seed, salt: "skin", mod: toneIndices.count)]]
        if stage == .senior {
            hairColor = AvatarPalette.grayHairColors[seedIndex(seed, salt: "hair", mod: AvatarPalette.grayHairColors.count)]
        } else {
            hairColor = AvatarPalette.hairColors[seedIndex(seed, salt: "hair", mod: AvatarPalette.hairColors.count)]
        }
        outfitColor = AvatarPalette.outfitColors[seedIndex(seed, salt: "outfit", mod: AvatarPalette.outfitColors.count)]
        accentColor = AvatarPalette.accentColors[seedIndex(seed, salt: "accent", mod: AvatarPalette.accentColors.count)]
    }
}

private enum HairStyle {
    case tuft, short, textured, long, bob, ponytail, bun, bald
    case afro, curly, mohawk, buzz, braids, pigtails
}

private enum EyeShape {
    case round, almond, narrow, wide
}

private enum EyebrowStyle {
    case straight, arched, thick, thin
}

struct AvatarView: View {
    let seed: String
    let gender: Gender
    let stage: LifeStage
    var country: String? = nil
    var isAlive: Bool = true
    var equipped: [Accessory] = []
    var equippedOutfit: Outfit? = nil
    var scars: Int = 0

    /// Younger characters are drawn noticeably smaller within the frame so
    /// the avatar visibly "grows up" across childhood rather than just
    /// swapping hairstyles at a fixed size.
    private var figureScale: CGFloat {
        switch stage {
        case .infant: return 0.55
        case .child: return 0.72
        case .teen: return 0.88
        case .adult, .senior: return 1.0
        }
    }

    var body: some View {
        Canvas { context, size in
            let scale = size.width / 200
            drawBackground(&context, scale: scale)
            if isAlive {
                context.drawLayer { layer in
                    let anchor = pt(100, 100, scale)
                    layer.translateBy(x: anchor.x, y: anchor.y)
                    layer.scaleBy(x: figureScale, y: figureScale)
                    layer.translateBy(x: -anchor.x, y: -anchor.y)
                    drawPerson(&layer, scale: scale)
                    for accessory in equipped {
                        drawAccessory(accessory, &layer, scale: scale)
                    }
                }
            } else {
                drawTombstone(&context, scale: scale)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var skinTone: Color {
        visualIdentity.skinTone
    }

    private var hairColor: Color {
        visualIdentity.hairColor
    }

    private var outfitColor: Color {
        equippedOutfit?.color ?? visualIdentity.outfitColor
    }

    private var outfitStyle: OutfitStyle {
        equippedOutfit?.style ?? .tshirt
    }

    private var irisColor: Color {
        AvatarPalette.irisColors[seedIndex(seed, salt: "eyes", mod: AvatarPalette.irisColors.count)]
    }

    private var accentColor: Color {
        visualIdentity.accentColor
    }

    private var region: CultureRegion {
        country.map { CountryData.profile(for: $0).region } ?? .angloWestern
    }

    private var visualIdentity: AvatarVisualIdentity {
        AvatarVisualIdentity(seed: seed, stage: stage, region: region)
    }

    private var hairStyle: HairStyle {
        if stage == .infant { return .tuft }
        if gender == .male {
            if stage == .senior {
                return seedIndex(seed, salt: "balding", mod: 100) < 45 ? .bald : .short
            }
            if stage == .adult {
                if seedIndex(seed, salt: "balding", mod: 100) < 18 { return .bald }
            }
            switch seedIndex(seed, salt: "male-style", mod: 6) {
            case 0: return .textured
            case 1: return .afro
            case 2: return .mohawk
            case 3: return .buzz
            case 4: return .curly
            default: return .short
            }
        }
        if stage == .senior { return .bun }
        switch seedIndex(seed, salt: "female-style", mod: 7) {
        case 0: return .bob
        case 1: return .ponytail
        case 2: return .afro
        case 3: return .curly
        case 4: return .braids
        case 5: return .pigtails
        default: return .long
        }
    }

    private var eyeShape: EyeShape {
        switch seedIndex(seed, salt: "eye-shape", mod: 4) {
        case 0: return .round
        case 1: return .almond
        case 2: return .narrow
        default: return .wide
        }
    }

    private var eyebrowStyle: EyebrowStyle {
        switch seedIndex(seed, salt: "eyebrow-style", mod: 4) {
        case 0: return .straight
        case 1: return .arched
        case 2: return .thick
        default: return .thin
        }
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
        let gradient = Gradient(colors: [
            accentColor.lighter(by: 0.1).opacity(0.55),
            accentColor.opacity(0.32),
            tint.opacity(0.2),
            Color.white.opacity(0.06),
        ])
        context.fill(
            Path(ellipseIn: rect(0, 0, 200, 200, scale)),
            with: .radialGradient(gradient, center: pt(96, 82, scale), startRadius: 0, endRadius: 118 * scale)
        )

        if isAlive {
            drawBackgroundDetails(&context, scale: scale)
        }

        // Vignette to deepen the rim and make the portrait pop forward.
        context.stroke(
            Path(ellipseIn: rect(2, 2, 196, 196, scale)),
            with: .color(.black.opacity(0.08)),
            lineWidth: 6 * scale
        )
        context.stroke(
            Path(ellipseIn: rect(4, 4, 192, 192, scale)),
            with: .color(.white.opacity(0.6)),
            lineWidth: 3 * scale
        )
    }

    private func drawBackgroundDetails(_ context: inout GraphicsContext, scale: CGFloat) {
        switch seedIndex(seed, salt: "backdrop", mod: 3) {
        case 0:
            for angle in stride(from: 0.0, to: 360.0, by: 30.0) {
                let radians = angle * .pi / 180
                var ray = Path()
                ray.move(to: pt(100 + CGFloat(cos(radians)) * 72, 88 + CGFloat(sin(radians)) * 72, scale))
                ray.addLine(to: pt(100 + CGFloat(cos(radians)) * 96, 88 + CGFloat(sin(radians)) * 96, scale))
                context.stroke(ray, with: .color(.white.opacity(0.34)), lineWidth: 5 * scale)
            }
        case 1:
            for index in 0..<10 {
                let x = CGFloat(20 + ((index * 37) % 160))
                let y = CGFloat(18 + ((index * 53) % 150))
                let diameter = CGFloat(index.isMultiple(of: 3) ? 8 : 4)
                context.fill(Path(ellipseIn: rect(x, y, diameter, diameter, scale)), with: .color(.white.opacity(0.38)))
            }
        default:
            for offset in [CGFloat(-18), 8, 34] {
                var wave = Path()
                wave.move(to: pt(-10, 56 + offset, scale))
                wave.addCurve(
                    to: pt(210, 66 + offset, scale),
                    control1: pt(50, 18 + offset, scale),
                    control2: pt(150, 112 + offset, scale)
                )
                context.stroke(wave, with: .color(.white.opacity(0.28)), lineWidth: 4 * scale)
            }
        }
    }

    private var hairGradient: Gradient {
        Gradient(colors: [hairColor.opacity(0.82), hairColor, hairColor.opacity(0.65)])
    }

    private var skinGradient: Gradient {
        Gradient(colors: [skinTone.lighter(by: 0.12), skinTone, skinTone.darker(by: 0.08)])
    }

    private func drawPerson(_ context: inout GraphicsContext, scale: CGFloat) {
        let headRect = rect(55, 35, 90, 100, scale)

        // Soft contact shadow grounds the whole figure.
        context.fill(
            Path(ellipseIn: rect(44, 206, 112, 14, scale)),
            with: .color(.black.opacity(0.14))
        )

        // Hair silhouettes behind the head give each portrait a distinct outline.
        switch hairStyle {
        case .long:
            context.fill(Path(roundedRect: rect(58, 55, 26, 120, scale), cornerRadius: 13 * scale), with: .linearGradient(hairGradient, startPoint: pt(58, 55, scale), endPoint: pt(84, 175, scale)))
            context.fill(Path(roundedRect: rect(116, 55, 26, 120, scale), cornerRadius: 13 * scale), with: .linearGradient(hairGradient, startPoint: pt(116, 55, scale), endPoint: pt(142, 175, scale)))
        case .bob:
            context.fill(Path(roundedRect: rect(48, 48, 104, 112, scale), cornerRadius: 44 * scale), with: .linearGradient(hairGradient, startPoint: pt(48, 48, scale), endPoint: pt(152, 160, scale)))
        case .ponytail:
            context.fill(Path(ellipseIn: rect(128, 56, 38, 88, scale)), with: .linearGradient(hairGradient, startPoint: pt(128, 56, scale), endPoint: pt(166, 144, scale)))
        case .braids:
            context.fill(Path(roundedRect: rect(60, 58, 14, 110, scale), cornerRadius: 7 * scale), with: .linearGradient(hairGradient, startPoint: pt(60, 58, scale), endPoint: pt(74, 168, scale)))
            context.fill(Path(roundedRect: rect(126, 58, 14, 110, scale), cornerRadius: 7 * scale), with: .linearGradient(hairGradient, startPoint: pt(126, 58, scale), endPoint: pt(140, 168, scale)))
            for y in stride(from: CGFloat(66), through: CGFloat(158), by: 12) {
                context.fill(Path(ellipseIn: rect(59, y, 16, 8, scale)), with: .color(hairColor.darker(by: 0.1)))
                context.fill(Path(ellipseIn: rect(125, y, 16, 8, scale)), with: .color(hairColor.darker(by: 0.1)))
            }
        case .pigtails:
            context.fill(Path(ellipseIn: rect(38, 54, 32, 60, scale)), with: .linearGradient(hairGradient, startPoint: pt(38, 54, scale), endPoint: pt(70, 114, scale)))
            context.fill(Path(ellipseIn: rect(130, 54, 32, 60, scale)), with: .linearGradient(hairGradient, startPoint: pt(130, 54, scale), endPoint: pt(162, 114, scale)))
        default:
            break
        }

        drawOutfitBase(&context, scale: scale)

        // Neck
        context.fill(Path(roundedRect: rect(85, 128, 30, 30, scale), cornerRadius: 8 * scale), with: .color(skinTone.darker(by: 0.04)))

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
        case .short:
            context.fill(Path(ellipseIn: rect(50, 22, 100, 80, scale)), with: .linearGradient(hairGradient, startPoint: pt(50, 22, scale), endPoint: pt(150, 102, scale)))
        case .textured, .curly:
            for (x, y, diameter) in [(55, 34, 34), (76, 22, 40), (103, 20, 42), (128, 34, 32)] {
                context.fill(Path(ellipseIn: rect(CGFloat(x), CGFloat(y), CGFloat(diameter), CGFloat(diameter), scale)), with: .linearGradient(hairGradient, startPoint: pt(CGFloat(x), CGFloat(y), scale), endPoint: pt(CGFloat(x) + CGFloat(diameter), CGFloat(y) + CGFloat(diameter), scale)))
            }
        case .afro:
            context.fill(Path(ellipseIn: rect(38, 10, 124, 110, scale)), with: .linearGradient(hairGradient, startPoint: pt(38, 10, scale), endPoint: pt(162, 120, scale)))
            for (x, y, diameter) in [(40, 46, 22), (34, 68, 20), (142, 50, 22), (148, 72, 18)] {
                context.fill(Path(ellipseIn: rect(CGFloat(x), CGFloat(y), CGFloat(diameter), CGFloat(diameter), scale)), with: .color(hairColor.opacity(0.9)))
            }
        case .mohawk:
            context.fill(Path(ellipseIn: rect(48, 60, 104, 40, scale)), with: .color(skinTone.darker(by: 0.06)))
            var strip = Path()
            strip.move(to: pt(90, 10, scale))
            strip.addLine(to: pt(110, 10, scale))
            strip.addLine(to: pt(104, 64, scale))
            strip.addLine(to: pt(96, 64, scale))
            strip.closeSubpath()
            context.fill(strip, with: .linearGradient(hairGradient, startPoint: pt(100, 10, scale), endPoint: pt(100, 64, scale)))
        case .buzz:
            context.fill(Path(ellipseIn: rect(52, 26, 96, 72, scale)), with: .color(hairColor.opacity(0.7)))
        case .braids, .pigtails:
            context.fill(Path(ellipseIn: rect(50, 20, 100, 70, scale)), with: .linearGradient(hairGradient, startPoint: pt(50, 20, scale), endPoint: pt(150, 90, scale)))
        case .long, .bob, .ponytail, .bun:
            context.fill(Path(ellipseIn: rect(48, 20, 104, 84, scale)), with: .linearGradient(hairGradient, startPoint: pt(48, 20, scale), endPoint: pt(152, 104, scale)))
        case .bald:
            break
        }

        // Face
        context.fill(
            Path(ellipseIn: headRect),
            with: .radialGradient(skinGradient, center: pt(92, 68, scale), startRadius: 4 * scale, endRadius: 70 * scale)
        )

        // Bun sits on top-back of the head for the senior female style
        if hairStyle == .bun {
            context.fill(Path(ellipseIn: rect(88, 18, 24, 22, scale)), with: .color(hairColor))
        }

        // A little shine for a fully bald head
        if hairStyle == .bald {
            context.fill(Path(ellipseIn: rect(88, 30, 22, 12, scale)), with: .color(.white.opacity(0.22)))
        }

        if hasFreckles {
            drawFreckles(&context, scale: scale)
        }

        drawEyebrows(&context, scale: scale)

        // Eyes
        drawEye(&context, cx: 83, cy: 88, scale: scale)
        drawEye(&context, cx: 117, cy: 88, scale: scale)

        drawNoseAndMouth(&context, scale: scale)
        drawHairTexture(&context, scale: scale)

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

    private func drawOutfitBase(_ context: inout GraphicsContext, scale: CGFloat) {
        // Torso / shoulders
        context.fill(Path(ellipseIn: rect(38, 148, 124, 82, scale)), with: .color(.black.opacity(0.10)))
        let shirtGradient = Gradient(colors: [outfitColor.lighter(by: 0.1), outfitColor, outfitColor.darker(by: 0.12)])

        switch outfitStyle {
        case .tank:
            context.fill(
                Path(roundedRect: rect(52, 150, 96, 90, scale), cornerRadius: 34 * scale),
                with: .linearGradient(shirtGradient, startPoint: pt(57, 150, scale), endPoint: pt(143, 215, scale))
            )
            context.fill(Path(roundedRect: rect(62, 140, 10, 18, scale), cornerRadius: 4 * scale), with: .color(outfitColor))
            context.fill(Path(roundedRect: rect(128, 140, 10, 18, scale), cornerRadius: 4 * scale), with: .color(outfitColor))
        case .dress:
            var dress = Path()
            dress.move(to: pt(62, 150, scale))
            dress.addLine(to: pt(28, 218, scale))
            dress.addLine(to: pt(172, 218, scale))
            dress.addLine(to: pt(138, 150, scale))
            dress.closeSubpath()
            context.fill(dress, with: .linearGradient(shirtGradient, startPoint: pt(45, 150, scale), endPoint: pt(155, 218, scale)))
        case .hoodie:
            context.fill(
                Path(roundedRect: rect(36, 148, 128, 92, scale), cornerRadius: 42 * scale),
                with: .linearGradient(shirtGradient, startPoint: pt(41, 148, scale), endPoint: pt(159, 215, scale))
            )
            context.fill(Path(ellipseIn: rect(72, 126, 56, 34, scale)), with: .color(outfitColor.darker(by: 0.08)))
        case .jacket:
            context.fill(
                Path(roundedRect: rect(40, 150, 120, 90, scale), cornerRadius: 36 * scale),
                with: .linearGradient(shirtGradient, startPoint: pt(45, 150, scale), endPoint: pt(155, 215, scale))
            )
            context.fill(Path(roundedRect: rect(40, 150, 14, 85, scale), cornerRadius: 6 * scale), with: .color(outfitColor.darker(by: 0.18)))
            context.fill(Path(roundedRect: rect(146, 150, 14, 85, scale), cornerRadius: 6 * scale), with: .color(outfitColor.darker(by: 0.18)))
        default:
            context.fill(
                Path(roundedRect: rect(40, 150, 120, 90, scale), cornerRadius: 40 * scale),
                with: .linearGradient(shirtGradient, startPoint: pt(45, 150, scale), endPoint: pt(155, 215, scale))
            )
        }

        if outfitStyle != .dress {
            context.fill(
                Path(roundedRect: rect(40, 150, 120, 20, scale), cornerRadius: 30 * scale),
                with: .color(.white.opacity(0.14))
            )
        }

        if outfitStyle == .suit {
            var lapelLeft = Path()
            lapelLeft.move(to: pt(84, 152, scale))
            lapelLeft.addLine(to: pt(94, 182, scale))
            lapelLeft.addLine(to: pt(100, 160, scale))
            lapelLeft.closeSubpath()
            var lapelRight = Path()
            lapelRight.move(to: pt(116, 152, scale))
            lapelRight.addLine(to: pt(106, 182, scale))
            lapelRight.addLine(to: pt(100, 160, scale))
            lapelRight.closeSubpath()
            context.fill(lapelLeft, with: .color(.black.opacity(0.55)))
            context.fill(lapelRight, with: .color(.black.opacity(0.55)))
            var tie = Path()
            tie.move(to: pt(97, 158, scale))
            tie.addLine(to: pt(103, 158, scale))
            tie.addLine(to: pt(100, 205, scale))
            tie.closeSubpath()
            context.fill(tie, with: .color(accentColor))
        }

        context.fill(Path(roundedRect: rect(90, 148, 20, 16, scale), cornerRadius: 6 * scale), with: .color(skinTone))

        if outfitStyle != .suit {
            drawOutfitDetails(&context, scale: scale)
        }
    }

    private func drawOutfitDetails(_ context: inout GraphicsContext, scale: CGFloat) {
        let detail = accentColor.opacity(0.85)
        switch seedIndex(seed, salt: "shirt-detail", mod: 4) {
        case 0:
            var collar = Path()
            collar.move(to: pt(82, 151, scale))
            collar.addLine(to: pt(100, 169, scale))
            collar.addLine(to: pt(118, 151, scale))
            context.stroke(collar, with: .color(.white.opacity(0.75)), lineWidth: 4 * scale)
        case 1:
            for y in stride(from: CGFloat(166), through: CGFloat(194), by: 10) {
                var stripe = Path()
                stripe.move(to: pt(53, y, scale))
                stripe.addLine(to: pt(147, y, scale))
                context.stroke(stripe, with: .color(.white.opacity(0.23)), lineWidth: 4 * scale)
            }
        case 2:
            context.fill(Path(ellipseIn: rect(92, 167, 16, 16, scale)), with: .color(detail))
            var star = Path()
            star.move(to: pt(100, 169, scale))
            star.addLine(to: pt(103, 176, scale))
            star.addLine(to: pt(110, 177, scale))
            star.addLine(to: pt(104, 182, scale))
            star.addLine(to: pt(106, 189, scale))
            star.addLine(to: pt(100, 185, scale))
            star.addLine(to: pt(94, 189, scale))
            star.addLine(to: pt(96, 182, scale))
            star.addLine(to: pt(90, 177, scale))
            star.addLine(to: pt(97, 176, scale))
            star.closeSubpath()
            context.fill(star, with: .color(.white.opacity(0.82)))
        default:
            var zipper = Path()
            zipper.move(to: pt(100, 158, scale))
            zipper.addLine(to: pt(100, 205, scale))
            context.stroke(zipper, with: .color(.white.opacity(0.42)), lineWidth: 2 * scale)
            context.fill(Path(ellipseIn: rect(96, 170, 8, 8, scale)), with: .color(detail))
        }
    }

    private func drawHairTexture(_ context: inout GraphicsContext, scale: CGFloat) {
        guard hairStyle != .bald && hairStyle != .tuft else { return }
        let highlight = Color.white.opacity(0.13)

        switch hairStyle {
        case .textured, .curly:
            for x in stride(from: CGFloat(66), through: CGFloat(132), by: 16) {
                var curl = Path()
                curl.addArc(center: pt(x, 48, scale), radius: 9 * scale, startAngle: .degrees(190), endAngle: .degrees(520), clockwise: false)
                context.stroke(curl, with: .color(highlight), lineWidth: 2 * scale)
            }
        case .afro:
            for (x, y) in [(55, 40), (80, 24), (105, 20), (130, 30), (145, 55)] {
                var curl = Path()
                curl.addArc(center: pt(CGFloat(x), CGFloat(y), scale), radius: 7 * scale, startAngle: .degrees(180), endAngle: .degrees(500), clockwise: false)
                context.stroke(curl, with: .color(highlight), lineWidth: 1.5 * scale)
            }
        case .braids, .pigtails:
            for x in [CGFloat(68), 84, 116, 132] {
                var strand = Path()
                strand.move(to: pt(x, 37, scale))
                strand.addQuadCurve(to: pt(x + (x < 100 ? -5 : 5), 68, scale), control: pt(x + (x < 100 ? 6 : -6), 52, scale))
                context.stroke(strand, with: .color(highlight), lineWidth: 2 * scale)
            }
        case .long, .bob, .ponytail, .bun:
            for x in [CGFloat(68), 84, 116, 132] {
                var strand = Path()
                strand.move(to: pt(x, 37, scale))
                strand.addQuadCurve(to: pt(x + (x < 100 ? -5 : 5), 68, scale), control: pt(x + (x < 100 ? 6 : -6), 52, scale))
                context.stroke(strand, with: .color(highlight), lineWidth: 2 * scale)
            }
        case .short, .buzz:
            var sweep = Path()
            sweep.move(to: pt(64, 49, scale))
            sweep.addQuadCurve(to: pt(132, 49, scale), control: pt(102, 24, scale))
            context.stroke(sweep, with: .color(highlight), lineWidth: 3 * scale)
        case .mohawk:
            var stripe = Path()
            stripe.move(to: pt(97, 14, scale))
            stripe.addLine(to: pt(99, 60, scale))
            context.stroke(stripe, with: .color(highlight), lineWidth: 1.5 * scale)
        case .tuft, .bald:
            break
        }
    }

    private func drawEyebrows(_ context: inout GraphicsContext, scale: CGFloat) {
        let color = hairColor.opacity(0.85)
        switch eyebrowStyle {
        case .straight:
            context.fill(Path(roundedRect: rect(74, 76, 18, 4, scale), cornerRadius: 2 * scale), with: .color(color))
            context.fill(Path(roundedRect: rect(108, 76, 18, 4, scale), cornerRadius: 2 * scale), with: .color(color))
        case .arched:
            var left = Path()
            left.move(to: pt(74, 79, scale))
            left.addQuadCurve(to: pt(92, 75, scale), control: pt(83, 70, scale))
            var right = Path()
            right.move(to: pt(108, 75, scale))
            right.addQuadCurve(to: pt(126, 79, scale), control: pt(117, 70, scale))
            context.stroke(left, with: .color(color), lineWidth: 3 * scale)
            context.stroke(right, with: .color(color), lineWidth: 3 * scale)
        case .thick:
            context.fill(Path(roundedRect: rect(73, 74, 19, 7, scale), cornerRadius: 3 * scale), with: .color(color))
            context.fill(Path(roundedRect: rect(108, 74, 19, 7, scale), cornerRadius: 3 * scale), with: .color(color))
        case .thin:
            context.fill(Path(roundedRect: rect(75, 77, 16, 2.5, scale), cornerRadius: 1.25 * scale), with: .color(color))
            context.fill(Path(roundedRect: rect(109, 77, 16, 2.5, scale), cornerRadius: 1.25 * scale), with: .color(color))
        }
    }

    private func drawNoseAndMouth(_ context: inout GraphicsContext, scale: CGFloat) {
        var nose = Path()
        nose.move(to: pt(100, 91, scale))
        nose.addQuadCurve(to: pt(96, 104, scale), control: pt(102, 101, scale))
        nose.addQuadCurve(to: pt(104, 104, scale), control: pt(100, 108, scale))
        context.stroke(nose, with: .color(.black.opacity(0.18)), lineWidth: 1.5 * scale)

        let expression = seedIndex(seed, salt: "expression", mod: 3)
        var mouth = Path()
        mouth.move(to: pt(88, 115, scale))
        if expression == 0 {
            mouth.addQuadCurve(to: pt(112, 115, scale), control: pt(100, 126, scale))
        } else if expression == 1 {
            mouth.addQuadCurve(to: pt(112, 114, scale), control: pt(100, 120, scale))
        } else {
            mouth.addQuadCurve(to: pt(112, 116, scale), control: pt(100, 112, scale))
        }
        context.stroke(mouth, with: .color(Color(red: 0.42, green: 0.16, blue: 0.18).opacity(0.78)), lineWidth: 2.5 * scale)
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
        let (w, h): (CGFloat, CGFloat)
        switch eyeShape {
        case .round: (w, h) = (15, 13)
        case .almond: (w, h) = (17, 10)
        case .narrow: (w, h) = (16, 7.5)
        case .wide: (w, h) = (19, 11)
        }
        context.fill(Path(ellipseIn: rect(cx - w / 2, cy - h / 2, w, h, scale)), with: .color(.white))
        let irisSize = min(h * 0.82, 8)
        let irisGradient = Gradient(colors: [irisColor.lighter(by: 0.2), irisColor, irisColor.darker(by: 0.25)])
        context.fill(
            Path(ellipseIn: rect(cx - irisSize / 2, cy - irisSize / 2, irisSize, irisSize, scale)),
            with: .radialGradient(irisGradient, center: pt(cx - 1.5, cy - 1.5, scale), startRadius: 0, endRadius: 6 * scale)
        )
        context.fill(Path(ellipseIn: rect(cx - 2, cy - 2, 3.5, 3.5, scale)), with: .color(.black))
        context.fill(Path(ellipseIn: rect(cx - 2.8, cy - 3.4, 1.8, 1.8, scale)), with: .color(.white.opacity(0.9)))
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

        case "tie", "tie_striped":
            var knot = Path()
            knot.move(to: pt(94, 150, scale))
            knot.addLine(to: pt(106, 150, scale))
            knot.addLine(to: pt(102, 160, scale))
            knot.addLine(to: pt(98, 160, scale))
            knot.closeSubpath()
            var body = Path()
            body.move(to: pt(98, 160, scale))
            body.addLine(to: pt(102, 160, scale))
            body.addLine(to: pt(108, 205, scale))
            body.addLine(to: pt(100, 215, scale))
            body.addLine(to: pt(92, 205, scale))
            body.closeSubpath()
            context.fill(knot, with: .color(accessory.color))
            context.fill(body, with: .color(accessory.color))
            if accessory.id == "tie_striped" {
                for y in stride(from: CGFloat(165), through: CGFloat(205), by: 10) {
                    var stripe = Path()
                    stripe.move(to: pt(92, y, scale))
                    stripe.addLine(to: pt(108, y - 6, scale))
                    context.stroke(stripe, with: .color(.white.opacity(0.5)), lineWidth: 2.5 * scale)
                }
            }

        case "gold_chain":
            var chain = Path()
            chain.addArc(center: pt(100, 148, scale), radius: 22 * scale, startAngle: .degrees(15), endAngle: .degrees(165), clockwise: false)
            context.stroke(chain, with: .color(accessory.color), lineWidth: 3.5 * scale)
            context.fill(Path(ellipseIn: rect(93, 168, 14, 14, scale)), with: .color(accessory.color))
            context.stroke(Path(ellipseIn: rect(93, 168, 14, 14, scale)), with: .color(.white.opacity(0.4)), lineWidth: 1 * scale)

        case "headband":
            var band = Path()
            band.addArc(center: pt(100, 60, scale), radius: 48 * scale, startAngle: .degrees(200), endAngle: .degrees(340), clockwise: false)
            context.stroke(band, with: .color(accessory.color), lineWidth: 8 * scale)

        case "bandana":
            var band = Path()
            band.addArc(center: pt(100, 58, scale), radius: 50 * scale, startAngle: .degrees(195), endAngle: .degrees(345), clockwise: false)
            context.stroke(band, with: .color(accessory.color), lineWidth: 10 * scale)
            var knot = Path()
            knot.move(to: pt(140, 62, scale))
            knot.addLine(to: pt(150, 72, scale))
            knot.addLine(to: pt(150, 56, scale))
            knot.closeSubpath()
            context.fill(knot, with: .color(accessory.color.opacity(0.85)))

        case "flowercrown":
            for angle in stride(from: -60.0, through: 60.0, by: 24.0) {
                let radians = angle * .pi / 180
                let x = 100 + CGFloat(sin(radians)) * 50
                let y = 38 - CGFloat(cos(radians)) * 46
                context.fill(Path(ellipseIn: rect(x - 5, y - 5, 10, 10, scale)), with: .color(.white))
                context.fill(Path(ellipseIn: rect(x - 2, y - 2, 4, 4, scale)), with: .color(.yellow))
            }

        case "stud_earrings":
            context.fill(Path(ellipseIn: rect(51, 92, 7, 7, scale)), with: .color(accessory.color))
            context.fill(Path(ellipseIn: rect(142, 92, 7, 7, scale)), with: .color(accessory.color))

        case "hoop_earrings":
            context.stroke(Path(ellipseIn: rect(50, 92, 9, 14, scale)), with: .color(accessory.color), lineWidth: 2 * scale)
            context.stroke(Path(ellipseIn: rect(141, 92, 9, 14, scale)), with: .color(accessory.color), lineWidth: 2 * scale)

        case "watch":
            context.fill(Path(roundedRect: rect(38, 222, 20, 9, scale), cornerRadius: 4 * scale), with: .color(accessory.color))
            context.fill(Path(ellipseIn: rect(43, 219, 10, 10, scale)), with: .color(accessory.color.opacity(0.9)))
            context.stroke(Path(ellipseIn: rect(43, 219, 10, 10, scale)), with: .color(.white.opacity(0.5)), lineWidth: 1 * scale)

        case "bracelet":
            context.fill(Path(roundedRect: rect(142, 222, 20, 8, scale), cornerRadius: 4 * scale), with: .color(accessory.color))

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
