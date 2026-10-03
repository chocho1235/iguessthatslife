import SwiftUI

struct CareerView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var feedback: String?
    @State private var interviewSession: JobInterviewSession?

    var character: Character { viewModel.character! }

    private var countryProfile: CountryProfile {
        CountryData.profile(for: character.country)
    }

    private var tuitionCost: Int {
        Int(Double(3000) * countryProfile.salaryMultiplier)
    }

    private func scaledSalary(_ job: Job) -> Int {
        Int(Double(job.baseSalary) * countryProfile.salaryMultiplier)
    }

    var body: some View {
        NavigationStack {
            List {
                if let feedback {
                    Section {
                        Text(feedback)
                            .font(.subheadline.bold())
                            .foregroundStyle(.blue)
                    }
                }

                Section("Education") {
                    if character.educationLevel == .university {
                        Label("Graduate of \(character.universityName ?? "University")", systemImage: "graduationcap.fill")
                            .font(.subheadline.bold())
                            .foregroundStyle(.green)
                    } else if character.stage == .teen || character.stage == .adult {
                        ForEach(countryProfile.universities, id: \.self) { university in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(university).font(.subheadline.bold())
                                    Text("Tuition $\(tuitionCost) · Requires 50 Smarts")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button("Enroll") {
                                    withAnimation { feedback = viewModel.enrollInUniversity(university) }
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(character.stats.smarts < 50 || character.cash < tuitionCost)
                            }
                            .padding(.vertical, 2)
                        }
                    } else {
                        Text("Too young for university yet.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                if let progress = character.activeCareer {
                    CareerLadderSection(viewModel: viewModel, progress: progress, feedback: $feedback)
                } else if let job = character.job {
                    Section("Current Job") {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(job.title).font(.subheadline.bold())
                            Text("\(job.category) · ~$\(scaledSalary(job))/yr")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Button("Quit Job") {
                            withAnimation { feedback = viewModel.quitJob() }
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }

                if character.hasCriminalRecord {
                    Section {
                        Label("You have a criminal record\(character.convictions.isEmpty ? "" : " (\(character.convictions.joined(separator: ", ")))"). Some employers won't hire you.", systemImage: "doc.text.fill")
                            .font(.caption)
                            .foregroundStyle(.purple)
                    }
                }

                if character.stage == .adult || character.stage == .senior {
                    SpecialCareersSection(viewModel: viewModel, feedback: $feedback)
                }

                Section("Available Jobs") {
                    let jobs = JobData.available(stage: character.stage, educationLevel: character.educationLevel, country: character.country)
                        .filter { $0.id != character.job?.id }
                    if jobs.isEmpty {
                        Text(character.stage == .child || character.stage == .infant
                             ? "Too young to work."
                             : "No jobs available right now.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(jobs) { job in
                            let cleared = JobData.passesBackgroundCheck(job, record: character.criminalRecord)
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(job.title).font(.subheadline.bold())
                                    Text("\(job.category) · ~$\(scaledSalary(job))/yr\(job.requiresDegree ? " · Requires Degree" : "")")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    if let check = JobData.backgroundCheckLabel(for: job) {
                                        Label(cleared ? check : "Your criminal record rules you out", systemImage: cleared ? "checkmark.shield" : "xmark.shield.fill")
                                            .font(.caption2.bold())
                                            .foregroundStyle(cleared ? Color.secondary : Color.red)
                                    }
                                }
                                Spacer()
                                Button("Apply") {
                                    interviewSession = viewModel.startInterview(for: job)
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(!cleared)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
            .sheet(item: $interviewSession) { session in
                JobApplicationCutsceneView(
                    viewModel: viewModel,
                    session: session,
                    applicantSeed: character.fullName,
                    applicantGender: character.gender,
                    applicantStage: character.stage,
                    applicantCountry: character.country,
                    applicantScars: character.scars
                )
            }
            .navigationTitle("Career")
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
}

#Preview {
    let vm = GameViewModel()
    vm.startNewLife()
    return CareerView(viewModel: vm)
}
