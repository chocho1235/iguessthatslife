import SwiftUI

/// The Current Job section when you're on a career ladder: rank, role,
/// performance and the things you can do about them.
struct CareerLadderSection: View {
    @ObservedObject var viewModel: GameViewModel
    let progress: CareerProgress
    @Binding var feedback: String?
    @State private var showingRoles = false

    private var salaryMultiplier: Double {
        CountryData.profile(for: viewModel.character?.country ?? "").salaryMultiplier
    }

    var body: some View {
        if let track = progress.track, let rank = progress.rank, let role = progress.role {
            Section {
                HStack(spacing: 12) {
                    Image(systemName: track.icon)
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 46, height: 46)
                        .background(track.color.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(rank.title).font(.headline)
                        Text("\(role.title) · \(track.name)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("~$\(Int(Double(rank.salary) * role.payMultiplier * salaryMultiplier))/yr · \(progress.yearsInCareer) yr\(progress.yearsInCareer == 1 ? "" : "s") served\(progress.medals > 0 ? " · \(progress.medals) medal\(progress.medals == 1 ? "" : "s")" : "")")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                rankLadder(track)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Performance").font(.caption.bold())
                        Spacer()
                        Text("\(progress.performance)/100")
                            .font(.caption.bold())
                            .monospacedDigit()
                    }
                    ProgressView(value: Double(progress.performance), total: 100)
                        .tint(performanceColor)
                    Text(nextRankText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Button {
                        withAnimation { feedback = viewModel.workHard() }
                    } label: {
                        Label("Work Hard", systemImage: "bolt.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(progress.workedHardThisYear)

                    Button {
                        withAnimation { feedback = viewModel.seekPromotion() }
                    } label: {
                        Label("Go for Promotion", systemImage: "arrow.up.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(track.color)
                    .disabled(progress.triedPromotionThisYear || progress.nextRank == nil)
                }

                Button {
                    showingRoles = true
                } label: {
                    Label("Change Role (\(track.roles.count) roles)", systemImage: "arrow.triangle.swap")
                }

                Button("Resign from the \(track.name)", role: .destructive) {
                    withAnimation { feedback = viewModel.quitJob() }
                }
            } header: {
                Text("Your Career")
            } footer: {
                Text("Role: \(role.summary) \(riskText(role.risk))")
            }
            .sheet(isPresented: $showingRoles) {
                RolePickerView(viewModel: viewModel, progress: progress, feedback: $feedback)
            }
        }
    }

    private var performanceColor: Color {
        switch progress.performance {
        case ..<30: return .red
        case ..<60: return .orange
        default: return .green
        }
    }

    private var nextRankText: String {
        guard let next = progress.nextRank else { return "You've reached the top rank." }
        if let blocker = viewModel.promotionBlocker(progress) {
            return "Next: \(next.title). \(blocker)"
        }
        return "Next: \(next.title). You're eligible! Promotions can also come on their own each year."
    }

    private func rankLadder(_ track: CareerTrack) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(Array(track.ranks.enumerated()), id: \.offset) { index, rank in
                    Text(rank.title)
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(index == progress.rankIndex ? track.color : (index < progress.rankIndex ? track.color.opacity(0.25) : Color.secondary.opacity(0.12)))
                        .foregroundStyle(index == progress.rankIndex ? Color.white : Color.primary)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

private func riskText(_ risk: Double) -> String {
    switch risk {
    case ..<0.1: return "Safe."
    case ..<0.35: return "Some danger."
    case ..<0.6: return "Dangerous."
    default: return "Very dangerous."
    }
}

private struct RolePickerView: View {
    @ObservedObject var viewModel: GameViewModel
    let progress: CareerProgress
    @Binding var feedback: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if let track = progress.track {
                    ForEach(track.roles) { role in
                        let blocker = viewModel.roleBlocker(role, in: progress)
                        Button {
                            feedback = viewModel.switchRole(to: role.id)
                            dismiss()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(role.title).font(.subheadline.bold())
                                    Text(role.summary)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("Pay x\(String(format: "%.2f", role.payMultiplier)) · \(riskText(role.risk))")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if let blocker {
                                    Text(blocker)
                                        .font(.caption2.bold())
                                        .foregroundStyle(role.id == progress.roleID ? Color.green : Color.red)
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                        }
                        .disabled(blocker != nil)
                    }
                }
            }
            .navigationTitle("Roles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

/// Every career ladder you could sign up for, with what it takes to get in.
struct SpecialCareersSection: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var feedback: String?
    @State private var joiningTrack: CareerTrackChoice?

    private struct CareerTrackChoice: Identifiable {
        let id: String
    }

    var body: some View {
        Section {
            ForEach(CareerData.all) { track in
                let blocker = viewModel.careerJoinBlocker(track)
                HStack(spacing: 12) {
                    Image(systemName: track.icon)
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(track.color.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(track.name).font(.subheadline.bold())
                        Text(track.summary)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text("\(track.ranks.count) ranks · \(track.ranks.first?.title ?? "") to \(track.ranks.last?.title ?? "")")
                            .font(.caption2.bold())
                            .foregroundStyle(track.color)
                        if let blocker {
                            Text(blocker)
                                .font(.caption2.bold())
                                .foregroundStyle(.red)
                        }
                    }
                    Spacer(minLength: 0)
                    Button("Join") {
                        joiningTrack = CareerTrackChoice(id: track.id)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(track.color)
                    .disabled(blocker != nil)
                }
                .padding(.vertical, 2)
            }
        } header: {
            Text("Special Careers")
        } footer: {
            Text("Climb the ranks, switch roles and earn promotions. Joining replaces your current job.")
        }
        .confirmationDialog(
            "Pick your starting role",
            isPresented: Binding(get: { joiningTrack != nil }, set: { if !$0 { joiningTrack = nil } }),
            titleVisibility: .visible,
            presenting: joiningTrack.flatMap { CareerData.byID[$0.id] }
        ) { track in
            ForEach(track.entryRoleIDs, id: \.self) { roleID in
                if let role = track.role(roleID) {
                    Button(role.title) {
                        withAnimation { feedback = viewModel.joinCareer(track, roleID: roleID) }
                    }
                }
            }
        } message: { track in
            Text("You'll start as \(track.ranks.first?.title ?? "a recruit"). More roles open up as you rank up.")
        }
    }
}
