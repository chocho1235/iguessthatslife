import SwiftUI

struct MigrationQuizView: View {
    @ObservedObject var viewModel: GameViewModel
    let session: MigrationQuizSession
    @Environment(\.dismiss) private var dismiss

    @State private var questionIndex = 0
    @State private var answers: [Int] = []
    @State private var outcome: MigrationOutcome?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if let outcome {
                    resultCard(outcome)
                } else {
                    Text("Visa Interview — \(session.destinationCountry)")
                        .font(.headline)
                        .padding(.top, 12)

                    Text("Question \(questionIndex + 1) of \(session.questions.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(session.questions[questionIndex].prompt)
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    VStack(spacing: 10) {
                        ForEach(Array(session.questions[questionIndex].options.enumerated()), id: \.offset) { index, option in
                            Button {
                                selectAnswer(index)
                            } label: {
                                Text(option)
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.bottom, 24)
            .navigationTitle("Visa Application")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if outcome != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
            }
            .sheet(item: $viewModel.pendingLegalTrouble) { trouble in
                LegalTroubleView(viewModel: viewModel, trouble: trouble) { _ in }
            }
        }
    }

    private func selectAnswer(_ index: Int) {
        answers.append(index)
        if questionIndex + 1 < session.questions.count {
            withAnimation { questionIndex += 1 }
        } else {
            withAnimation { outcome = viewModel.resolveMigration(session, answers: answers) }
        }
    }

    @ViewBuilder
    private func resultCard(_ outcome: MigrationOutcome) -> some View {
        VStack(spacing: 14) {
            Image(systemName: outcome.approved ? "checkmark.seal.fill" : "xmark.seal.fill")
                .font(.system(size: 54))
                .foregroundStyle(outcome.approved ? .green : .red)

            if outcome.approved {
                Text("Visa Approved!")
                    .font(.title2.bold())
                    .foregroundStyle(.green)
                Text("You answered \(outcome.correctCount)/\(outcome.totalQuestions) correctly and moved to \(outcome.destinationCountry) for $\(outcome.amountCharged).")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("Visa Denied")
                    .font(.title2.bold())
                    .foregroundStyle(.red)
                Text(outcome.note ?? "You only answered \(outcome.correctCount)/\(outcome.totalQuestions) correctly. The application fee of $\(outcome.amountCharged) is non-refundable.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 40)
    }
}

#Preview {
    let vm = GameViewModel()
    vm.startNewLife()
    let session = MigrationData.quizSession(for: "Japan")!
    return MigrationQuizView(viewModel: vm, session: session)
}
