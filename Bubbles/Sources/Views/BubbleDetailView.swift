import SwiftUI

struct BubbleDetailView: View {
    @ObservedObject var store: BubbleStore
    let bubbleID: UUID
    let onPop: (Bubble) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var newGoal = ""
    @State private var confirmingDelete = false

    private var bubble: Bubble? { store.bubbles.first { $0.id == bubbleID } }

    var body: some View {
        NavigationStack {
            if let bubble {
                content(bubble)
            } else {
                Color.clear.onAppear { dismiss() }
            }
        }
    }

    private func content(_ bubble: Bubble) -> some View {
        let now = Date()
        return List {
            Section {
                VStack(spacing: 12) {
                    TextField("Name", text: titleBinding)
                        .font(.system(.title, design: .rounded).weight(.heavy))
                        .multilineTextAlignment(.center)

                    Text("\(bubble.scope.title) bubble · \(bubble.periodLabel)")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)

                    ProgressView(value: bubble.progress)
                        .tint(bubble.color)
                        .scaleEffect(y: 2)
                        .padding(.vertical, 6)

                    HStack {
                        Label("\(bubble.doneCount) of \(bubble.goals.count) done", systemImage: "checkmark.circle")
                        Spacer()
                        Label(bubble.timeLeftLabel(at: now), systemImage: "clock")
                    }
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))

                    Text("Must be done by \(deadlineText(bubble))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }

            if bubble.isComplete {
                Section {
                    Button {
                        dismiss()
                        onPop(bubble)
                    } label: {
                        Label("Every goal done. Pop it!", systemImage: "sparkles")
                            .font(.system(.headline, design: .rounded))
                            .frame(maxWidth: .infinity)
                    }
                    .tint(bubble.color)
                }
            } else if bubble.isExpired(at: now) {
                Section {
                    Text("Time ran out on this one. You can keep the goals that are left and give it another go.")
                        .font(.subheadline)
                    Button("Move to this \(bubble.scope.title.lowercased())") {
                        var moved = bubble
                        moved.periodStart = Bubble.startOfPeriod(bubble.scope, containing: Date())
                        store.update(moved)
                    }
                }
            }

            Section("Goals") {
                ForEach(bubble.goals) { goal in
                    Button {
                        withAnimation { store.toggleGoal(goal.id, in: bubble.id) }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: goal.isDone ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .foregroundStyle(goal.isDone ? bubble.color : .secondary)
                            Text(goal.text)
                                .strikethrough(goal.isDone)
                                .foregroundStyle(goal.isDone ? .secondary : .primary)
                        }
                    }
                }
                .onDelete { offsets in
                    var edited = bubble
                    edited.goals.remove(atOffsets: offsets)
                    store.update(edited)
                }

                HStack {
                    TextField("Add a goal", text: $newGoal)
                        .onSubmit(addGoal)
                    Button(action: addGoal) {
                        Image(systemName: "plus.circle.fill").font(.title2)
                    }
                    .disabled(newGoal.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            Section {
                Button("Delete bubble", role: .destructive) { confirmingDelete = true }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
        .confirmationDialog("Delete this bubble?", isPresented: $confirmingDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                dismiss()
                store.delete(bubble.id)
            }
        }
    }

    private var titleBinding: Binding<String> {
        Binding(
            get: { bubble?.title ?? "" },
            set: { newValue in
                guard var edited = bubble else { return }
                edited.title = newValue
                store.update(edited)
            }
        )
    }

    private func addGoal() {
        let text = newGoal.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, var edited = bubble else { return }
        edited.goals.append(Goal(text: text))
        store.update(edited)
        newGoal = ""
    }
}
