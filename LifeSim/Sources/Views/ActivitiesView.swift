import SwiftUI

struct ActivitiesView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var feedback: String?

    var character: Character { viewModel.character! }

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

                Section("Things to Do") {
                    ForEach(ActivityKind.allCases) { kind in
                        HStack(spacing: 14) {
                            Image(systemName: kind.icon)
                                .font(.title2)
                                .foregroundStyle(.purple)
                                .frame(width: 36)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(kind.rawValue).font(.subheadline.bold())
                                Text(kind.subtitle)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("Do It") {
                                withAnimation { feedback = viewModel.performActivity(kind) }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Activities")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
    return ActivitiesView(viewModel: vm)
}
