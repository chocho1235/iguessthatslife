import SwiftUI

struct StatBarView: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(value)")
                    .font(.caption.bold())
                    .foregroundStyle(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                        .overlay {
                            Capsule().stroke(.black.opacity(0.04), lineWidth: 1)
                        }

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.75), color],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, geo.size.width * CGFloat(value) / 100))
                        .overlay(alignment: .top) {
                            Capsule()
                                .fill(.white.opacity(0.35))
                                .frame(height: 3)
                                .padding(.horizontal, 3)
                                .padding(.top, 1.5)
                        }
                        .shadow(color: color.opacity(0.5), radius: 3, y: 1)
                }
            }
            .frame(height: 9)
        }
    }
}

#Preview {
    VStack(spacing: 14) {
        StatBarView(label: "Health", value: 75, color: .red)
        StatBarView(label: "Happiness", value: 48, color: .yellow)
        StatBarView(label: "Smarts", value: 90, color: .blue)
    }
    .padding()
}
