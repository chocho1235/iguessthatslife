import SwiftUI

/// Walks an arrest through the full court procedure: booking, a bail
/// hearing, hiring a lawyer, then a courtroom cutscene where you enter
/// your plea and hear the verdict.
struct LegalTroubleView: View {
    @ObservedObject var viewModel: GameViewModel
    let trouble: LegalTrouble
    /// Called with the verdict summary once the player leaves the courtroom.
    let onFinish: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    private enum Step {
        case booking
        case bail
        case lawyer
        case courtroom
    }

    @State private var step: Step = .booking
    @State private var paidBail = false
    @State private var lawyer: LawyerOption = .selfRepresented

    private var cash: Int { viewModel.character?.cash ?? 0 }

    var body: some View {
        Group {
            if step == .courtroom {
                CourtroomCutscene(viewModel: viewModel, trouble: trouble, paidBail: paidBail, lawyer: lawyer) { summary in
                    viewModel.closeCourtCase()
                    onFinish(summary)
                    dismiss()
                }
                .transition(.opacity)
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        stepHeader
                        switch step {
                        case .booking: bookingStep
                        case .bail: bailStep
                        case .lawyer, .courtroom: lawyerStep
                        }
                    }
                    .padding(24)
                }
            }
        }
        .animation(.easeInOut, value: step)
        .interactiveDismissDisabled()
    }

    // MARK: - Steps

    private var stepHeader: some View {
        let steps: [(Step, String)] = [(.booking, "Booking"), (.bail, "Bail"), (.lawyer, "Lawyer"), (.courtroom, "Court")]
        let currentIndex = steps.firstIndex { $0.0 == step } ?? 0
        return HStack(spacing: 6) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, item in
                VStack(spacing: 4) {
                    Capsule()
                        .fill(index <= currentIndex ? Color.indigo : Color.secondary.opacity(0.25))
                        .frame(height: 5)
                    Text(item.1)
                        .font(.caption2.bold())
                        .foregroundStyle(index == currentIndex ? Color.primary : Color.secondary)
                }
            }
        }
    }

    private var bookingStep: some View {
        VStack(spacing: 18) {
            icon("hand.raised.slash.fill", color: .red)
            VStack(spacing: 6) {
                Text("You've Been Arrested")
                    .font(.title2.bold())
                Text(trouble.arrestStory)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(trouble.charges, id: \.self) { charge in
                    HStack {
                        Text(charge.displayName).font(.subheadline.bold())
                        Spacer()
                        Text(charge.severity.label)
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(severityColor(charge.severity).opacity(0.15))
                            .foregroundStyle(severityColor(charge.severity))
                            .clipShape(Capsule())
                    }
                }
                Divider()
                infoRow("Evidence against you", trouble.evidenceLabel)
                infoRow("Possible sentence", sentenceText)
                if let seized = trouble.seizedWeapon {
                    infoRow("Seized by police", seized)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))

            primaryButton("Go to Bail Hearing", systemImage: "arrow.right") { step = .bail }
        }
    }

    private var bailStep: some View {
        VStack(spacing: 18) {
            icon("building.columns.fill", color: .orange)
            VStack(spacing: 6) {
                Text("Bail Hearing")
                    .font(.title2.bold())
                Text(trouble.bailDenied
                     ? "The judge says you're too dangerous to let out. Bail denied."
                     : "The judge set bail at $\(trouble.bailAmount). A bondsman will post it for a $\(trouble.bondsmanFee) fee you don't get back.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if trouble.bailDenied {
                primaryButton("Wait for Trial in a Cell", systemImage: "lock.fill") {
                    paidBail = false
                    step = .lawyer
                }
            } else {
                primaryButton("Pay the Bondsman $\(trouble.bondsmanFee)", systemImage: "dollarsign.circle.fill") {
                    paidBail = true
                    step = .lawyer
                }
                .disabled(cash < trouble.bondsmanFee)

                Button {
                    paidBail = false
                    step = .lawyer
                } label: {
                    VStack(spacing: 2) {
                        Text("Stay in Custody")
                        Text("Free, but it's miserable and you might lose your job")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.bordered)
                .tint(.red)

                if cash < trouble.bondsmanFee {
                    Text("You only have $\(cash).")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var lawyerStep: some View {
        VStack(spacing: 16) {
            icon("briefcase.fill", color: .indigo)
            VStack(spacing: 6) {
                Text("Get a Lawyer")
                    .font(.title2.bold())
                Text("Good lawyers are not cheap, but they'll tell you how to plead and fight for you in court. You have $\(cash).")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            ForEach(LawyerOption.allCases) { option in
                lawyerRow(option)
            }
        }
    }

    // MARK: - Pieces

    private func lawyerRow(_ option: LawyerOption) -> some View {
        let cost = viewModel.lawyerCost(option, for: trouble)
        let affordable = cash >= cost
        let odds = 1 - viewModel.trialConvictionChance(option, for: trouble)

        return Button {
            lawyer = option
            step = .courtroom
        } label: {
            HStack(spacing: 12) {
                Image(systemName: option.icon)
                    .font(.title3)
                    .frame(width: 30)
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(option.title).font(.subheadline.bold())
                        Spacer()
                        Text(cost == 0 ? "Free" : "$\(cost)")
                            .font(.subheadline.bold())
                    }
                    Text(option.blurb)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                    Text("Chance of winning at trial: \(Self.oddsLabel(odds))")
                        .font(.caption2.bold())
                        .foregroundStyle(.indigo)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.indigo.opacity(affordable ? 0.10 : 0.04))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .opacity(affordable ? 1 : 0.45)
        }
        .buttonStyle(.plain)
        .disabled(!affordable)
    }

    private var sentenceText: String {
        let range = trouble.leadCharge.sentenceRange
        if range.upperBound == 0 { return "Fine and probation" }
        if range.lowerBound == 0 { return "Up to \(range.upperBound) year\(range.upperBound == 1 ? "" : "s")" }
        return "\(range.lowerBound) to \(range.upperBound) years"
    }

    static func oddsLabel(_ odds: Double) -> String {
        switch odds {
        case ..<0.15: return "Very low"
        case ..<0.35: return "Low"
        case ..<0.55: return "Fair"
        case ..<0.75: return "Good"
        default: return "Strong"
        }
    }

    private func severityColor(_ severity: ChargeSeverity) -> Color {
        switch severity {
        case .misdemeanor: return .orange
        case .felony: return .red
        case .seriousFelony: return .purple
        case .capital: return .primary
        }
    }

    private func icon(_ name: String, color: Color) -> some View {
        Image(systemName: name)
            .font(.system(size: 40, weight: .bold))
            .foregroundStyle(color)
            .padding()
            .background(color.opacity(0.14))
            .clipShape(Circle())
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption.bold())
        }
    }

    private func primaryButton(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.borderedProminent)
        .tint(.indigo)
    }
}

/// The courtroom itself: the judge reads the charges, your lawyer leans in
/// with advice, you enter a plea and (if you fight it) the jury decides.
private struct CourtroomCutscene: View {
    @ObservedObject var viewModel: GameViewModel
    let trouble: LegalTrouble
    let paidBail: Bool
    let lawyer: LawyerOption
    let onDone: (String) -> Void

    private enum Speaker {
        case judge, prosecutor, lawyer, player, foreperson
    }

    private struct Line {
        let speaker: Speaker
        let text: String
        /// The moment the verdict is read out — show the stamp and play the
        /// sound when this line comes up.
        var revealsVerdict = false
    }

    private enum Phase {
        case opening, plea, trial, deliberating, reading, done
    }

    @State private var phase: Phase = .opening
    @State private var lines: [Line] = []
    @State private var lineIndex = 0
    @State private var advice: LawyerAdvice?
    @State private var verdict: CourtVerdict?
    @State private var showStamp = false
    @State private var arrived = false

    private var character: Character? { viewModel.character }
    private var currentLine: Line? { lines.indices.contains(lineIndex) ? lines[lineIndex] : nil }

    var body: some View {
        VStack(spacing: 0) {
            courtroom
                .frame(height: 300)
            dialogueArea
                .frame(maxHeight: .infinity)
        }
        .background(Color(.systemBackground))
        .onAppear(perform: start)
    }

    // MARK: - Script

    private func start() {
        advice = viewModel.lawyerAdvice(lawyer, for: trouble)
        let name = character?.fullName ?? "Defendant"
        var opening: [Line] = [
            Line(speaker: .judge, text: "All rise. This court is now in session."),
            Line(speaker: .judge, text: "\(name), you are charged with \(trouble.chargeDescription)."),
            Line(speaker: .prosecutor, text: prosecutorOpening),
        ]
        if let advice, let lawyerName = lawyer.lawyerName {
            opening.append(Line(speaker: .lawyer, text: "(\(lawyerName) leans over and whispers) \(advice.line)"))
        } else {
            opening.append(Line(speaker: .player, text: "(No lawyer. Nobody to ask. You're on your own here.)"))
        }
        opening.append(Line(speaker: .judge, text: "\(character?.firstName ?? "Defendant"), how do you plead?"))
        lines = opening
        lineIndex = 0
        withAnimation(.easeOut(duration: 0.8)) { arrived = true }
    }

    private func enterPlea(guilty: Bool) {
        SoundManager.shared.play(.tap)
        let result = viewModel.resolveCourtCase(paidBail: paidBail, lawyer: lawyer, pleadGuilty: guilty)
        verdict = result

        var next: [Line] = []
        if guilty {
            next.append(Line(speaker: .player, text: "Guilty, your honor."))
            if let advice {
                next.append(Line(speaker: .lawyer, text: advice.recommendsGuilty ? "Smart move. Let me handle the rest." : "...That is not what we talked about."))
            }
            next.append(Line(speaker: .judge, text: "The court accepts your guilty plea.", revealsVerdict: true))
            next.append(Line(speaker: .judge, text: sentenceLine(result)))
            lines = next
            lineIndex = 0
            phase = .reading
            return
        }

        next.append(Line(speaker: .player, text: "Not guilty, your honor."))
        next.append(Line(speaker: .prosecutor, text: prosecutorArgument))
        next.append(Line(speaker: lawyer == .selfRepresented ? .player : .lawyer, text: defenseArgument))
        next.append(Line(speaker: .judge, text: "Thank you both. The jury will now leave to deliberate."))
        lines = next
        lineIndex = 0
        phase = .trial
    }

    private func advance() {
        guard arrived else { return }
        if lineIndex + 1 < lines.count {
            withAnimation { lineIndex += 1 }
            if lines[lineIndex].revealsVerdict { revealVerdict() }
            return
        }
        switch phase {
        case .opening:
            withAnimation { phase = .plea }
        case .trial:
            withAnimation { phase = .deliberating }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                guard let verdict else { return }
                lines = [
                    Line(speaker: .judge, text: "Has the jury reached a verdict?"),
                    Line(speaker: .foreperson, text: "We have, your honor. On the charge of \(trouble.chargeDescription), we find the defendant..."),
                    Line(speaker: .foreperson, text: verdict.guilty ? "GUILTY." : "NOT GUILTY.", revealsVerdict: true),
                    Line(speaker: .judge, text: sentenceLine(verdict)),
                ]
                lineIndex = 0
                withAnimation { phase = .reading }
            }
        case .reading:
            withAnimation { phase = .done }
        case .plea, .deliberating, .done:
            break
        }
    }

    private func revealVerdict() {
        guard let verdict else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) { showStamp = true }
        if verdict.guilty {
            SoundManager.shared.playSequence(verdict.years > 0 ? [.alert, .death] : [.alert])
        } else {
            SoundManager.shared.playSequence([.cheer, .achievement])
        }
    }

    private var prosecutorOpening: String {
        switch trouble.evidence {
        case ..<0.4: return "Your honor, the state will show the defendant was involved. We are confident."
        case ..<0.6: return "Your honor, we have witnesses and evidence tying the defendant to this crime."
        default: return "Your honor, the evidence here is overwhelming. This should not take long."
        }
    }

    private var prosecutorArgument: String {
        var parts = ["Members of the jury, the defendant is guilty of \(trouble.leadCharge.displayName.lowercased())."]
        if let seized = trouble.seizedWeapon {
            parts.append("Officers took a \(seized.lowercased()) off them at the arrest.")
        }
        if trouble.evidence >= 0.6 {
            parts.append("The evidence speaks for itself.")
        } else {
            parts.append("Don't let them talk their way out of this.")
        }
        return parts.joined(separator: " ")
    }

    private var defenseArgument: String {
        switch lawyer {
        case .selfRepresented: return "I didn't do it! I mean... I'm not a lawyer, but you've got the wrong person."
        case .publicDefender: return "My client is, uh, a good person. Probably. Please consider that. Thank you."
        case .privateLawyer: return "The state's story has gaps you could drive a truck through. That's reasonable doubt."
        case .topAttorney: return "Not one witness can put my client at the scene with certainty. The state has wasted your time. Acquit."
        }
    }

    private func sentenceLine(_ verdict: CourtVerdict) -> String {
        guard verdict.guilty else { return "The defendant is found not guilty and is free to go. Court is adjourned." }
        let fine = verdict.fine > 0 ? " and a fine of $\(verdict.fine)" : ""
        if verdict.years > 0 {
            return "I sentence you to \(verdict.years) year\(verdict.years == 1 ? "" : "s") in prison\(fine). Bailiff, take them away."
        }
        return "I sentence you to probation\(fine). Don't let me see you in here again."
    }

    // MARK: - Scene

    private var courtroom: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                // Wood panel wall and floor
                LinearGradient(colors: [Color(red: 0.42, green: 0.27, blue: 0.16), Color(red: 0.30, green: 0.19, blue: 0.11)], startPoint: .top, endPoint: .bottom)
                HStack(spacing: w / 7) {
                    ForEach(0..<6, id: \.self) { _ in
                        Rectangle().fill(Color.black.opacity(0.12)).frame(width: 3)
                    }
                }
                Rectangle()
                    .fill(Color(red: 0.55, green: 0.38, blue: 0.24))
                    .frame(height: h * 0.32)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                // Seal behind the judge
                Circle()
                    .fill(Color(red: 0.85, green: 0.68, blue: 0.25).opacity(0.85))
                    .overlay(Image(systemName: "building.columns.fill").font(.title2).foregroundStyle(Color(red: 0.42, green: 0.27, blue: 0.16)))
                    .frame(width: 56, height: 56)
                    .position(x: w / 2, y: 34)

                // Judge and the bench
                person(.judge, seed: "Judge Harlow", gender: .female, outfit: "suit_black", size: 74)
                    .position(x: w / 2, y: 92)
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(red: 0.36, green: 0.22, blue: 0.12))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black.opacity(0.25), lineWidth: 2))
                    .frame(width: w * 0.62, height: 48)
                    .position(x: w / 2, y: 146)
                Text("🔨")
                    .font(.system(size: 26))
                    .rotationEffect(.degrees(showStamp ? -35 : 0))
                    .position(x: w / 2 + w * 0.22, y: 128)

                // Defense table (left) and prosecution table (right)
                if let lawyerName = lawyer.lawyerName {
                    person(.lawyer, seed: lawyerName, gender: lawyer.lawyerGender, outfit: lawyer == .topAttorney ? "suit_black" : "suit_gray", size: 62)
                        .position(x: arrived ? w * 0.34 : -80, y: h - 72)
                }
                if let character {
                    person(.player, seed: character.fullName, gender: character.gender, stage: character.stage, country: character.country, outfit: character.equippedOutfitID, scars: character.scars, size: 66)
                        .position(x: arrived ? w * 0.14 : -60, y: h - 70)
                }
                person(.prosecutor, seed: "Prosecutor Vance", gender: .male, outfit: "suit_navy", size: 62)
                    .position(x: arrived ? w * 0.84 : w + 80, y: h - 72)
                tables(width: w, height: h)

                if showStamp, let verdict {
                    Text(verdict.guilty ? "GUILTY" : "NOT GUILTY")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(verdict.guilty ? Color.red : Color.green)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 6)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(verdict.guilty ? Color.red : Color.green, lineWidth: 5))
                        .background(Color.white.opacity(0.85).clipShape(RoundedRectangle(cornerRadius: 8)))
                        .rotationEffect(.degrees(-10))
                        .position(x: w / 2, y: h / 2)
                        .transition(.scale(scale: 2.4).combined(with: .opacity))
                }
            }
        }
        .clipped()
    }

    private func tables(width w: CGFloat, height h: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 0.36, green: 0.22, blue: 0.12))
                .frame(width: w * 0.46, height: 22)
                .position(x: w * 0.24, y: h - 24)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 0.36, green: 0.22, blue: 0.12))
                .frame(width: w * 0.30, height: 22)
                .position(x: w * 0.84, y: h - 24)
        }
    }

    private func person(_ speaker: Speaker, seed: String, gender: Gender, stage: LifeStage = .adult, country: String? = nil, outfit: String?, scars: Int = 0, size: CGFloat) -> some View {
        let speaking = currentLine?.speaker == speaker && phase != .plea && phase != .deliberating && phase != .done
        return AvatarView(seed: seed, gender: gender, stage: stage, country: country, equippedOutfit: outfit.flatMap { OutfitData.byID[$0] }, scars: scars)
            .frame(width: size, height: size)
            .background(Color.white)
            .clipShape(Circle())
            .overlay(Circle().stroke(speaking ? Color.yellow : Color.white.opacity(0.6), lineWidth: speaking ? 4 : 2))
            .scaleEffect(speaking ? 1.12 : 1)
            .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
            .animation(.spring(response: 0.3), value: speaking)
    }

    // MARK: - Dialogue

    @ViewBuilder
    private var dialogueArea: some View {
        switch phase {
        case .opening, .trial, .reading:
            if let currentLine {
                VStack(spacing: 14) {
                    dialogueBox(currentLine)
                    Text("Tap to continue")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding()
                .contentShape(Rectangle())
                .onTapGesture(perform: advance)
            }

        case .plea:
            VStack(spacing: 14) {
                dialogueBox(Line(speaker: .judge, text: "How do you plead?"))
                pleaButton(guilty: false)
                pleaButton(guilty: true)
                Spacer()
            }
            .padding()

        case .deliberating:
            VStack(spacing: 14) {
                ProgressView()
                    .controlSize(.large)
                Text("The jury is deliberating...")
                    .font(.headline)
                Text("Nobody in the room is breathing.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .done:
            if let verdict {
                VStack(spacing: 14) {
                    Text(verdict.summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button {
                        onDone(verdict.summary)
                    } label: {
                        Label(verdict.guilty && verdict.years > 0 ? "Go to Prison" : "Leave the Courthouse", systemImage: "door.left.hand.open")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(verdict.guilty ? .red : .green)
                    Spacer()
                }
                .padding()
            }
        }
    }

    private func pleaButton(guilty: Bool) -> some View {
        let recommended = advice.map { $0.recommendsGuilty == guilty } ?? false
        return Button {
            enterPlea(guilty: guilty)
        } label: {
            VStack(spacing: 3) {
                HStack(spacing: 6) {
                    Text(guilty ? "Plead Guilty" : "Plead Not Guilty")
                        .font(.headline)
                    if recommended {
                        Text("LAWYER'S PICK")
                            .font(.caption2.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.yellow)
                            .foregroundStyle(.black)
                            .clipShape(Capsule())
                    }
                }
                Text(guilty ? "Guaranteed conviction, about half the sentence" : "Go to trial and let the jury decide")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .buttonStyle(.borderedProminent)
        .tint(guilty ? .orange : .indigo)
    }

    private func dialogueBox(_ line: Line) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(speakerName(line.speaker).uppercased())
                .font(.caption.bold())
                .foregroundStyle(speakerColor(line.speaker))
            Text(line.text)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(speakerColor(line.speaker).opacity(0.4), lineWidth: 2))
        .id(line.text)
        .transition(.opacity)
    }

    private func speakerName(_ speaker: Speaker) -> String {
        switch speaker {
        case .judge: return "Judge Harlow"
        case .prosecutor: return "Prosecutor Vance"
        case .lawyer: return lawyer.lawyerName ?? "Your Lawyer"
        case .player: return character?.firstName ?? "You"
        case .foreperson: return "Jury Foreperson"
        }
    }

    private func speakerColor(_ speaker: Speaker) -> Color {
        switch speaker {
        case .judge: return .brown
        case .prosecutor: return .red
        case .lawyer: return .indigo
        case .player: return .blue
        case .foreperson: return .gray
        }
    }
}

#Preview {
    let vm = GameViewModel()
    vm.startNewLife()
    return LegalTroubleView(
        viewModel: vm,
        trouble: LegalTrouble(
            charges: [.armedRobbery, .weaponPossession],
            evidence: 0.62,
            bailAmount: 40_000,
            bondsmanFee: 6_000,
            privateLawyerCost: 60_000,
            topAttorneyCost: 210_000,
            seizedWeapon: "Handgun",
            arrestStory: "The clerk hit the panic button and police swarmed the store."
        ),
        onFinish: { _ in }
    )
}
