import SwiftUI

struct JobApplicationCutsceneView: View {
    @ObservedObject var viewModel: GameViewModel
    let session: JobInterviewSession
    let applicantSeed: String
    let applicantGender: Gender
    let applicantStage: LifeStage
    var applicantScars: Int = 0
    @Environment(\.dismiss) private var dismiss

    @State private var applicantArrived = false
    @State private var openerIndex = 0
    @State private var questionIndex = 0
    @State private var answers: [AnswerQuality] = []
    @State private var outcome: JobApplicationOutcome?

    private enum Phase {
        case opener
        case questions
        case result
    }

    private var phase: Phase {
        if outcome != nil { return .result }
        if openerIndex < session.opener.count { return .opener }
        return .questions
    }

    private var bubbleText: String? {
        switch phase {
        case .opener: return session.opener.isEmpty ? nil : session.opener[openerIndex]
        case .questions: return session.questions[questionIndex].prompt
        case .result: return nil
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            officeScene
                .frame(height: 280)

            VStack(spacing: 16) {
                Spacer(minLength: 8)
                content
                Spacer()
            }
            .padding(.bottom, 24)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.9)) {
                applicantArrived = true
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch phase {
        case .opener:
            Text("Tap to continue")
                .font(.caption)
                .foregroundStyle(.secondary)
                .contentShape(Rectangle())
                .padding()
                .onTapGesture {
                    guard applicantArrived else { return }
                    withAnimation { openerIndex += 1 }
                }

        case .questions:
            VStack(alignment: .leading, spacing: 10) {
                ForEach(session.questions[questionIndex].options) { option in
                    Button {
                        selectAnswer(option.quality)
                    } label: {
                        Text(option.text)
                            .font(.subheadline)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal)

        case .result:
            VStack(spacing: 20) {
                resultCard
                Text("Tap to finish")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
            .onTapGesture { dismiss() }
        }
    }

    private func selectAnswer(_ quality: AnswerQuality) {
        answers.append(quality)
        if questionIndex + 1 < session.questions.count {
            withAnimation { questionIndex += 1 }
        } else {
            outcome = viewModel.resolveInterview(session, answers: answers)
        }
    }

    private var officeScene: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Rectangle().fill(Color(red: 0.90, green: 0.90, blue: 0.95))
                Rectangle()
                    .fill(Color(red: 0.75, green: 0.70, blue: 0.62))
                    .frame(height: 60)

                VStack(spacing: 6) {
                    if applicantArrived, let bubbleText {
                        SpeechBubble(text: bubbleText)
                            .frame(maxWidth: 240)
                            .transition(.opacity)
                    }
                    AvatarView(seed: "Ms. Bennett", gender: .female, stage: .adult)
                        .frame(width: 90, height: 90)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                .position(x: geo.size.width * 0.68, y: geo.size.height - 110)

                AvatarView(seed: applicantSeed, gender: applicantGender, stage: applicantStage, scars: applicantScars)
                    .frame(width: 80, height: 80)
                    .background(Color.white)
                    .clipShape(Circle())
                    .position(x: applicantArrived ? geo.size.width * 0.30 : -60, y: geo.size.height - 96)
            }
        }
        .clipped()
    }

    @ViewBuilder
    private var resultCard: some View {
        if let outcome {
            VStack(spacing: 8) {
                switch outcome.result {
                case .hired:
                    Text("You got the job!")
                        .font(.title2.bold())
                        .foregroundStyle(.green)
                    Text(outcome.job.title)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                case .rejected:
                    Text("Not this time...")
                        .font(.title2.bold())
                        .foregroundStyle(.red)
                    Text("They went with another candidate for \(outcome.job.title).")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                case .fight:
                    Text("It got physical!")
                        .font(.title2.bold())
                        .foregroundStyle(.orange)
                    Text("Somehow the interview turned into a shouting match — and then a shoving match. You did not get the job at \(outcome.job.title).")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal)
            .transition(.opacity)
        }
    }
}

#Preview {
    let vm = GameViewModel()
    vm.startNewLife()
    return JobApplicationCutsceneView(
        viewModel: vm,
        session: JobInterviewSession(
            job: JobData.all[0],
            opener: ["Thanks for coming in — tell me about yourself.", "Let me review your application..."],
            questions: InterviewData.randomQuestions(count: 2, jobTitle: JobData.all[0].title)
        ),
        applicantSeed: "Ava Taylor",
        applicantGender: .female,
        applicantStage: .teen
    )
}
