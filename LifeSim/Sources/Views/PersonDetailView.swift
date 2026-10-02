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

    private var isMarried: Bool {
        if case .partner = person.ref { return viewModel.character?.partner?.isMarried ?? false }
        return false
    }

    private var remainingInteractions: Int { viewModel.remainingInteractions(for: person.ref) }
    private var outOfInteractions: Bool { remainingInteractions <= 0 }

    private var moodLabel: (text: String, color: Color)? {
        if viewModel.isInGreatMood(person.ref) { return ("In a great mood this year", .green) }
        if viewModel.isInBadMood(person.ref) { return ("Seems distant this year", .orange) }
        return nil
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

                    if person.isAlive {
                        HStack(spacing: 8) {
                            Label("\(remainingInteractions)/\(RelationshipHistory.yearlyBudget) interactions left this year", systemImage: "hourglass")
                                .font(.caption.bold())
                                .foregroundStyle(outOfInteractions ? .red : .secondary)
                            if let moodLabel {
                                Text("· \(moodLabel.text)")
                                    .font(.caption.bold())
                                    .foregroundStyle(moodLabel.color)
                            }
                        }
                        .padding(.horizontal)
                    }

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
                            if case .partner = person.ref {
                                if !isMarried {
                                    actionButton("Propose", icon: "heart.circle.fill", tint: .pink) {
                                        viewModel.propose()
                                    }
                                }
                                actionButton(isMarried ? "Divorce" : "Break Up", icon: "heart.slash.fill", tint: .gray) {
                                    viewModel.breakUp()
                                }
                            } else if viewModel.canAskOut(person.ref) {
                                actionButton("Ask Out", icon: "heart.fill", tint: .pink) {
                                    viewModel.askOut(person.ref)
                                }
                            }

                            actionButton("Spend Time", icon: "clock.fill", tint: .blue, disabled: outOfInteractions) {
                                viewModel.spendTime(with: person.ref)
                            }
                            actionButton("Give Gift ($\(giftCost))", icon: "gift.fill", tint: .purple, disabled: outOfInteractions || (viewModel.character?.cash ?? 0) < giftCost) {
                                viewModel.giveGift(with: person.ref, cost: giftCost)
                            }
                            actionButton("Ask for Money", icon: "dollarsign.circle.fill", tint: .green, disabled: outOfInteractions) {
                                viewModel.askForMoney(from: person.ref)
                            }
                            actionButton("Prank Them", icon: "theatermasks.fill", tint: .orange, disabled: outOfInteractions) {
                                viewModel.prank(person.ref)
                            }
                            actionButton("Argue", icon: "flame.fill", tint: .red, disabled: outOfInteractions) {
                                viewModel.argue(with: person.ref)
                            }
                            actionButton("Steal From Them", icon: "hand.raised.slash.fill", tint: .gray, disabled: outOfInteractions) {
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
        case .partner:
            return character.partner?.relationship ?? person.relationship
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
