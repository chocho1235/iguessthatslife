import SwiftUI

struct DoctorView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var feedback: String?
    @State private var checkupOutcome: CheckupOutcome?

    var character: Character { viewModel.character! }

    private var treatableDiagnosedConditions: [ActiveCondition] {
        character.conditions.filter { active in
            guard active.isDiagnosed, let condition = ConditionData.byID[active.conditionID] else { return false }
            return !condition.requiresGlasses
        }
    }

    private var totalTreatmentCost: Int {
        treatableDiagnosedConditions.reduce(0) { $0 + (ConditionData.byID[$1.conditionID]?.treatmentCost ?? 0) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                StatBarView(label: "Health", value: character.stats.health, color: .red)
                    .padding(.horizontal)
                    .padding(.top, 8)

                if let feedback {
                    Text(feedback)
                        .font(.subheadline.bold())
                        .foregroundStyle(.blue)
                        .padding(.horizontal)
                        .transition(.opacity)
                }

                List {
                    Section("Active Conditions") {
                        if character.conditions.isEmpty {
                            Text("No active health conditions. Great job!")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(character.conditions) { active in
                                conditionRow(active)
                            }
                            if treatableDiagnosedConditions.count > 1 {
                                Button("Treat All ($\(totalTreatmentCost))") {
                                    withAnimation { feedback = viewModel.treatAll() }
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.red)
                                .frame(maxWidth: .infinity)
                                .disabled(character.cash < totalTreatmentCost)
                            }
                        }
                    }

                    Section("Checkup") {
                        HStack(spacing: 14) {
                            Image(systemName: DoctorService.checkup.icon)
                                .font(.title2)
                                .frame(width: 36)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(DoctorService.checkup.rawValue).font(.subheadline.bold())
                                Text("The only way to find out what's wrong. Diagnoses every hidden condition.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("$\(DoctorService.checkup.cost)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("Visit") {
                                checkupOutcome = viewModel.performCheckup()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(character.cash < DoctorService.checkup.cost)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
            .sheet(item: $checkupOutcome) { outcome in
                CheckupCutsceneView(
                    outcome: outcome,
                    patientSeed: character.fullName,
                    patientGender: character.gender,
                    patientStage: character.stage,
                    patientCountry: character.country,
                    patientScars: character.scars
                )
            }
            .navigationTitle("Doctor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("💰 $\(character.cash)")
                        .font(.headline)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func conditionRow(_ active: ActiveCondition) -> some View {
        let condition = ConditionData.byID[active.conditionID]

        HStack(spacing: 14) {
            Image(systemName: active.isDiagnosed ? "cross.case.fill" : "questionmark.circle.fill")
                .font(.title2)
                .foregroundStyle(active.isDiagnosed ? (condition?.severity == .severe ? .red : .orange) : .gray)
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 2) {
                if active.isDiagnosed, let condition {
                    Text(condition.name).font(.subheadline.bold())
                    if condition.requiresGlasses {
                        Text("Fix this by equipping glasses from the Shop.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("\(condition.severity.rawValue) · treat with \(condition.severity.requiredService.rawValue) ($\(condition.treatmentCost))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("Unknown Illness").font(.subheadline.bold())
                    Text("Something's wrong — book a Checkup below to find out what.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if active.isDiagnosed, let condition, !condition.requiresGlasses {
                Button("Treat") {
                    withAnimation { feedback = viewModel.treat(active.id) }
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .disabled(character.cash < condition.treatmentCost)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let vm = GameViewModel()
    vm.startNewLife()
    return DoctorView(viewModel: vm)
}
