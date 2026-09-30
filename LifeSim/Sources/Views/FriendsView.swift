import SwiftUI

struct FriendsView: View {
    let friends: [Friend]
    let stage: LifeStage
    var onSelect: (PersonSelection) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Friends")
                .font(.headline)
            if friends.isEmpty {
                Text("No friends yet. Maybe next year!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(friends) { friend in
                    Button {
                        onSelect(
                            PersonSelection(
                                ref: .friend(friend.id),
                                name: friend.name,
                                gender: friend.gender,
                                stage: stage,
                                isAlive: true,
                                relationship: friend.relationship,
                                label: "Friend"
                            )
                        )
                    } label: {
                        HStack {
                            AvatarView(seed: friend.name, gender: friend.gender, stage: stage)
                                .frame(width: 40, height: 40)
                                .background(Color(.tertiarySystemBackground))
                                .clipShape(Circle())
                            VStack(alignment: .leading) {
                                Text(friend.name).font(.subheadline.bold())
                                Text("Friend")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(friend.relationship)%")
                                .font(.caption.bold())
                                .foregroundStyle(friend.relationship > 50 ? .green : .orange)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    FriendsView(
        friends: [Friend(name: "Sam Lee", gender: .male, relationship: 72)],
        stage: .teen,
        onSelect: { _ in }
    )
    .padding()
}
