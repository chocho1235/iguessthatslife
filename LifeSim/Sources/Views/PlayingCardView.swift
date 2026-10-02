import SwiftUI

/// A simple procedural playing card — no image assets, matching the rest of
/// the game's shape-and-text art style. Shared by the blackjack table and
/// the casino intro.
struct PlayingCardView: View {
    let card: Card
    var faceDown: Bool = false

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(faceDown ? AnyShapeStyle(cardBackStyle) : AnyShapeStyle(Color.white))
            .frame(width: 58, height: 82)
            .overlay {
                if faceDown {
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(.white.opacity(0.5), lineWidth: 2)
                        .padding(6)
                } else {
                    VStack(spacing: 2) {
                        Text(card.rank.label)
                            .font(.system(size: 20, weight: .bold))
                        Text(card.suit.rawValue)
                            .font(.system(size: 18))
                    }
                    .foregroundStyle(card.suit.isRed ? Color.red : Color.black)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.black.opacity(0.25), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
    }

    private var cardBackStyle: LinearGradient {
        LinearGradient(colors: [Color.indigo, Color.blue.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
