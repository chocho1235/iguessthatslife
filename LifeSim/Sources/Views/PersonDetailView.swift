import SwiftUI

struct PersonDetailView: View {
    @ObservedObject var viewModel: GameViewModel
    let person: PersonSelection
    @Environment(\.dismiss) private var dismiss
    @State private var feedback: String?

    private var giftCost: Int {
        guard let country = viewModel.character?.country else { return 15 }
        return max(1, Int(15 * CountryData.profile(for: country).salaryMultiplier))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    AvatarView(seed: person.name, gender: person.gender, stage: person.stage, country: person.country, isAlive: person.isAlive)
                        .frame(width: 120, height: 120)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Circle())

                    Text(person.name)
                        .font(.title2.bold())
                    Text(person.label)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    StatBarView(label: "Relationship", value: currentRelationship, color: .pink)
                        .padding(.horizontal)

                    if let feedback {
                        Text(feedback)
                            .font(.subheadline.bold())
                            .foregroundStyle(.blue)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .transition(.opacity)
                    }

                    if !person.isAlive {
                        Text("This person has passed away.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                    } else {
                        VStack(spacing: 12) {
                            actionButton("Spend Time", icon: "clock.fill", tint: .blue) {
                                viewModel.spendTime(with: person.ref)
                            }
                            actionButton("Give Gift ($\(giftCost))", icon: "gift.fill", tint: .purple, disabled: (viewModel.character?.cash ?? 0) < giftCost) {
                                viewModel.giveGift(with: person.ref, cost: giftCost)
                            }
                            actionButton("Ask for Money", icon: "dollarsign.circle.fill", tint: .green) {
                                viewModel.askForMoney(from: person.ref)
                            }
                            actionButton("Prank Them", icon: "theatermasks.fill", tint: .orange) {
                                viewModel.prank(person.ref)
                            }
                            actionButton("Argue", icon: "flame.fill", tint: .red) {
                                viewModel.argue(with: person.ref)
                            }
                            actionButton("Steal From Them", icon: "hand.raised.slash.fill", tint: .gray) {
                                viewModel.steal(from: person.ref)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func actionButton(_ title: String, icon: String, tint: Color, disabled: Bool = false, action: @escaping () -> String) -> some View {
        Button {
            withAnimation { feedback = action() }
        } label: {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.borderedProminent)
        .tint(tint)
        .disabled(disabled)
    }

    private var currentRelationship: Int {
        guard let character = viewModel.character else { return person.relationship }
        switch person.ref {
        case .family(let id):
            return character.family.first(where: { $0.id == id })?.relationship ?? person.relationship
        case .friend(let id):
            return character.friends.first(where: { $0.id == id })?.relationship ?? person.relationship
        case .stranger:
            return person.relationship
        }
    }
}

#Preview {
    let vm = GameViewModel()
    vm.startNewLife()
    return PersonDetailView(
        viewModel: vm,
        person: PersonSelection(ref: .family(UUID()), name: "Jane Smith", gender: .female, stage: .adult, isAlive: true, relationship: 72, label: "Mother")
    )
}
