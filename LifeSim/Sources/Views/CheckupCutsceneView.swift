import SwiftUI

struct CheckupCutsceneView: View {
    let outcome: CheckupOutcome
    let patientSeed: String
    let patientGender: Gender
    let patientStage: LifeStage
    var patientCountry: String? = nil
    var patientScars: Int = 0
    @Environment(\.dismiss) private var dismiss
    @State private var lineIndex = 0
    @State private var patientArrived = false

    private var isDone: Bool { lineIndex >= outcome.dialogue.count }

    var body: some View {
        VStack(spacing: 0) {
            officeScene
                .frame(height: 300)

            VStack(spacing: 20) {
                Spacer(minLength: 8)
                resultCard
                Spacer()
                Text(isDone ? "Tap to finish" : "Tap to continue")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)
            }
            .padding(.bottom, 30)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard patientArrived else { return }
            if isDone {
                dismiss()
            } else {
                withAnimation { lineIndex += 1 }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.9)) {
                patientArrived = true
            }
        }
    }

    private var officeScene: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Rectangle().fill(Color(red: 0.85, green: 0.92, blue: 0.97))
                Rectangle()
                    .fill(Color(red: 0.87, green: 0.80, blue: 0.68))
                    .frame(height: 60)

                VStack(spacing: 6) {
                    if patientArrived, !isDone, !outcome.dialogue.isEmpty {
                        SpeechBubble(text: outcome.dialogue[min(lineIndex, outcome.dialogue.count - 1)])
                            .frame(maxWidth: 230)
                            .transition(.opacity)
                    }
                    AvatarView(seed: "Dr. Whitfield", gender: .female, stage: .adult)
                        .frame(width: 90, height: 90)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                .position(x: geo.size.width * 0.68, y: geo.size.height - 110)

                AvatarView(seed: patientSeed, gender: patientGender, stage: patientStage, country: patientCountry, scars: patientScars)
                    .frame(width: 80, height: 80)
                    .background(Color.white)
                    .clipShape(Circle())
                    .position(x: patientArrived ? geo.size.width * 0.30 : -60, y: geo.size.height - 96)
            }
        }
        .clipped()
    }

    @ViewBuilder
    private var resultCard: some View {
        if isDone {
            VStack(spacing: 10) {
                if outcome.diagnosedConditions.isEmpty {
                    Text("You're in perfect health!")
                        .font(.title2.bold())
                        .foregroundStyle(.green)
                } else {
                    Text("You've been diagnosed with:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    ForEach(outcome.diagnosedConditions) { diagnosis in
                        VStack(spacing: 2) {
                            Text(diagnosis.name)
                                .font(.title2.bold())
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                            Text("Recommended: \(diagnosis.service.rawValue) ($\(diagnosis.service.cost))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .transition(.opacity)
        } else {
            Color.clear.frame(height: 60)
        }
    }
}

#Preview {
    CheckupCutsceneView(
        outcome: CheckupOutcome(
            dialogue: ["Hi there, let's take a look at you.", "Let me check your vitals..."],
            diagnosedConditions: [
                DiagnosedConditionInfo(name: "Flu", service: .treatment),
                DiagnosedConditionInfo(name: "Anxiety", service: .treatment),
            ]
        ),
        patientSeed: "Ava Taylor",
        patientGender: .female,
        patientStage: .child
    )
}
