import SwiftUI

struct NewBubbleView: View {
    let onCreate: (Bubble) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var scope: BubbleScope
    @State private var date = Date()
    @State private var goals: [Goal] = []
    @State private var newGoal = ""
    @State private var colorIndex: Int
    @FocusState private var goalFieldFocused: Bool

    init(colorIndex: Int, defaultScope: BubbleScope, onCreate: @escaping (Bubble) -> Void) {
        self.onCreate = onCreate
        _scope = State(initialValue: defaultScope)
        _colorIndex = State(initialValue: colorIndex % BubblePalette.colors.count)
    }

    private var draft: Bubble {
        Bubble(
            title: title.isEmpty ? "New bubble" : title,
            scope: scope,
            containing: date,
            goals: goals + (pendingGoal.map { [$0] } ?? []),
            colorIndex: colorIndex
        )
    }

    private var pendingGoal: Goal? {
        let text = newGoal.trimmingCharacters(in: .whitespaces)
        return text.isEmpty ? nil : Goal(text: text)
    }

    private var canCreate: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && !draft.goals.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        BubbleView(bubble: draft, now: Date(), wobble: 0)
                            .animation(.spring, value: scope)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }

                Section("Name") {
                    TextField("e.g. Get fit, Finish project", text: $title)
                }

                Section {
                    Picker("Length", selection: $scope) {
                        ForEach(BubbleScope.allCases) { Text($0.title).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    DatePicker("Which \(scope.title.lowercased())", selection: $date, displayedComponents: .date)
                } header: {
                    Text("Time frame")
                } footer: {
                    Text("\(draft.periodLabel). Goals must be done by \(deadlineText(draft)).")
                }

                Section("Goals") {
                    ForEach(goals) { goal in
                        Text(goal.text)
                    }
                    .onDelete { goals.remove(atOffsets: $0) }
                    HStack {
                        TextField("Add a goal", text: $newGoal)
                            .focused($goalFieldFocused)
                            .submitLabel(.next)
                            .onSubmit(addGoal)
                        Button(action: addGoal) {
                            Image(systemName: "plus.circle.fill").font(.title2)
                        }
                        .disabled(pendingGoal == nil)
                    }
                }

                Section("Colour") {
                    HStack(spacing: 12) {
                        ForEach(BubblePalette.colors.indices, id: \.self) { i in
                            Circle()
                                .fill(BubblePalette.color(i))
                                .frame(width: 32, height: 32)
                                .overlay(Circle().stroke(Color.primary, lineWidth: colorIndex == i ? 3 : 0))
                                .onTapGesture { colorIndex = i }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("New bubble")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Blow") {
                        var bubble = draft
                        bubble.title = title.trimmingCharacters(in: .whitespaces)
                        onCreate(bubble)
                        dismiss()
                    }
                    .bold()
                    .disabled(!canCreate)
                }
            }
        }
    }

    private func addGoal() {
        guard let goal = pendingGoal else { return }
        goals.append(goal)
        newGoal = ""
        goalFieldFocused = true
    }
}

func deadlineText(_ bubble: Bubble) -> String {
    // The deadline is the very start of the next period, so show the moment just before it.
    let lastMoment = bubble.deadline.addingTimeInterval(-1)
    return "the end of " + lastMoment.formatted(date: .abbreviated, time: .omitted)
}
