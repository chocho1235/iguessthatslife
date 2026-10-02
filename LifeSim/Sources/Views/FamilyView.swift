import SwiftUI

struct FamilyView: View {
    let family: [FamilyMember]
    var country: String? = nil
    var onSelect: (PersonSelection) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Family")
                .font(.headline)
            ForEach(family) { member in
                Button {
                    onSelect(
                        PersonSelection(
                            ref: .family(member.id),
                            name: member.name,
                            gender: member.gender,
                            stage: member.avatarStage,
                            isAlive: member.isAlive,
                            relationship: member.relationship,
                            label: member.relation.rawValue,
                            country: country
                        )
                    )
                } label: {
                    HStack {
                        AvatarView(seed: member.name, gender: member.gender, stage: member.avatarStage, country: country, isAlive: member.isAlive)
                            .frame(width: 40, height: 40)
                            .background(Color(.tertiarySystemBackground))
                            .clipShape(Circle())
                        VStack(alignment: .leading) {
                            Text(member.name).font(.subheadline.bold())
                            Text(member.isOwnChild ? "\(member.relation.rawValue) · Age \(member.age)" : member.relation.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("\(member.relationship)%")
                            .font(.caption.bold())
                            .foregroundStyle(member.relationship > 50 ? .green : .orange)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    FamilyView(
        family: [
            FamilyMember(name: "Jane Smith", relation: .mother, relationship: 80),
            FamilyMember(name: "John Smith", relation: .father, relationship: 65),
        ],
        onSelect: { _ in }
    )
    .padding()
}
