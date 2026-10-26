import SwiftUI

struct BubbleView: View {
    let bubble: Bubble
    let now: Date
    let wobble: Double

    private var expired: Bool { bubble.isExpired(at: now) }
    private var upcoming: Bool { !bubble.hasStarted(at: now) }
    private var tint: Color { expired ? .gray : bubble.color }

    var body: some View {
        let d = bubble.scope.diameter
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [tint.opacity(0.15), tint.opacity(0.45), tint.opacity(0.85)],
                        center: UnitPoint(x: 0.35, y: 0.3),
                        startRadius: 2,
                        endRadius: d * 0.7
                    )
                )

            // Soap film shine.
            Ellipse()
                .fill(Color.white.opacity(0.55))
                .frame(width: d * 0.28, height: d * 0.16)
                .rotationEffect(.degrees(-35))
                .offset(x: -d * 0.2, y: -d * 0.24)
                .blur(radius: 1.5)

            Circle()
                .stroke(Color.white.opacity(0.5), lineWidth: 1.5)

            // How far through the goals you are.
            Circle()
                .trim(from: 0, to: CGFloat(bubble.progress))
                .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(3)

            VStack(spacing: 2) {
                Text(bubble.title)
                    .font(.system(size: d * 0.13, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                Text("\(bubble.doneCount)/\(bubble.goals.count)")
                    .font(.system(size: d * 0.1, weight: .semibold, design: .rounded))
                    .opacity(0.9)
                Text(bubble.timeLeftLabel(at: now))
                    .font(.system(size: d * 0.085, weight: .medium, design: .rounded))
                    .opacity(0.85)
            }
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
            .padding(d * 0.16)

            if bubble.isComplete {
                Image(systemName: "sparkles")
                    .font(.system(size: d * 0.16))
                    .foregroundStyle(.yellow)
                    .offset(x: d * 0.32, y: -d * 0.32)
                    .opacity(0.6 + 0.4 * sin(wobble * 3))
            }
        }
        .frame(width: d, height: d)
        .shadow(color: tint.opacity(bubble.isComplete ? 0.9 : 0.35), radius: bubble.isComplete ? 18 : 8)
        // Bubbles breathe a little as they float.
        .scaleEffect(x: CGFloat(1 + 0.025 * sin(wobble)), y: CGFloat(1 - 0.025 * sin(wobble)))
        .opacity(upcoming ? 0.6 : 1)
        .saturation(expired ? 0.2 : 1)
    }
}

/// Little burst of droplets shown when a finished bubble is popped.
struct PopBurst: View {
    let color: Color
    @State private var go = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(color, lineWidth: go ? 0.5 : 6)
                .frame(width: go ? 200 : 60, height: go ? 200 : 60)
                .opacity(go ? 0 : 1)
            ForEach(0..<12, id: \.self) { i in
                let angle = Double(i) / 12 * 2 * .pi
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                    .offset(x: go ? CGFloat(cos(angle)) * 110 : 0, y: go ? CGFloat(sin(angle)) * 110 : 0)
                    .scaleEffect(go ? 0.2 : 1)
                    .opacity(go ? 0 : 1)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { go = true }
        }
    }
}
