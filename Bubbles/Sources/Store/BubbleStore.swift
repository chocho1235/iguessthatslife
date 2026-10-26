import Foundation

struct SaveData: Codable {
    var bubbles: [Bubble]
    var poppedCount: Int
}

final class BubbleStore: ObservableObject {
    @Published var bubbles: [Bubble] = [] { didSet { save() } }
    @Published var poppedCount = 0 { didSet { save() } }

    private var isLoading = false

    private static var fileURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("bubbles_save.json")
    }

    init() {
        load()
    }

    func add(_ bubble: Bubble) {
        bubbles.append(bubble)
    }

    func update(_ bubble: Bubble) {
        guard let i = bubbles.firstIndex(where: { $0.id == bubble.id }) else { return }
        bubbles[i] = bubble
    }

    func toggleGoal(_ goalID: UUID, in bubbleID: UUID) {
        guard let b = bubbles.firstIndex(where: { $0.id == bubbleID }),
              let g = bubbles[b].goals.firstIndex(where: { $0.id == goalID }) else { return }
        bubbles[b].goals[g].isDone.toggle()
    }

    func delete(_ bubbleID: UUID) {
        bubbles.removeAll { $0.id == bubbleID }
    }

    // Popping is the reward for finishing every goal in a bubble.
    func pop(_ bubbleID: UUID) {
        guard bubbles.contains(where: { $0.id == bubbleID }) else { return }
        delete(bubbleID)
        poppedCount += 1
    }

    var nextColorIndex: Int { bubbles.count }

    private func save() {
        guard !isLoading else { return }
        let data = SaveData(bubbles: bubbles, poppedCount: poppedCount)
        guard let encoded = try? JSONEncoder().encode(data) else { return }
        try? encoded.write(to: Self.fileURL, options: .atomic)
    }

    private func load() {
        isLoading = true
        defer { isLoading = false }
        guard let data = try? Data(contentsOf: Self.fileURL),
              let saved = try? JSONDecoder().decode(SaveData.self, from: data) else { return }
        bubbles = saved.bubbles
        poppedCount = saved.poppedCount
    }
}
