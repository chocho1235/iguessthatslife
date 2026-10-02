import SwiftUI

struct PartnerView: View {
    let partner: Partner
    let stage: LifeStage
    var country: String? = nil
    var onSelect: (PersonSelection) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(partner.isMarried ? "Spouse" : "Partner")
                .font(.headline)
            Button {
                onSelect(
                    PersonSelection(
                        ref: .partner,
                        name: partner.name,
                        gender: partner.gender,
                        stage: stage,
                        isAlive: true,
                        relationship: partner.relationship,
                        label: partner.isMarried ? "Spouse" : "Partner",
                        country: country
                    )
                )
            } label: {
                HStack {
                    AvatarView(seed: partner.name, gender: partner.gender, stage: stage, country: country)
                        .frame(width: 40, height: 40)
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(Circle())
                    VStack(alignment: .leading) {
                        Text(partner.name).font(.subheadline.bold())
                        Text(partner.isMarried ? "Married \(partner.yearsTogether) year\(partner.yearsTogether == 1 ? "" : "s")" : "Together \(partner.yearsTogether) year\(partner.yearsTogether == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(partner.relationship)%")
                        .font(.caption.bold())
                        .foregroundStyle(partner.relationship > 50 ? .green : .orange)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    PartnerView(
        partner: Partner(name: "Alex Rivera", gender: .female, relationship: 78, isMarried: true, yearsTogether: 4),
        stage: .adult,
        onSelect: { _ in }
    )
    .padding()
}
