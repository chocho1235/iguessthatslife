import SwiftUI

struct ContentView: View {
    @StateObject private var store = BubbleStore()
    @State private var field = FloatField()
    @State private var filter: BubbleScope?
    @State private var showingNew = false
    @State private var openBubbleID: UUID?
    @State private var bursts: [Burst] = []

    struct Burst: Identifiable {
        let id = UUID()
        let position: CGPoint
        let color: Color
    }

    private var visible: [Bubble] {
        guard let filter else { return store.bubbles }
        return store.bubbles.filter { $0.scope == filter }
    }

    var body: some View {
        ZStack {
            background

            GeometryReader { geo in
                let bounds = CGRect(origin: .zero, size: geo.size)
                TimelineView(.animation) { timeline in
                    let now = timeline.date
                    let _ = stepField(to: now, in: bounds)
                    ZStack {
                        ForEach(visible) { bubble in
                            if let pos = field.position(of: bubble.id) {
                                BubbleView(bubble: bubble, now: now, wobble: wobble(for: bubble, at: now))
                                    .position(pos)
                                    .onTapGesture { openBubbleID = bubble.id }
                                    .gesture(
                                        DragGesture(minimumDistance: 6, coordinateSpace: .named("field"))
                                            .onChanged { field.drag(bubble.id, to: $0.location) }
                                            .onEnded { field.release(bubble.id, velocity: $0.velocity) }
                                    )
                            }
                        }
                        ForEach(bursts) { burst in
                            PopBurst(color: burst.color).position(burst.position)
                        }
                    }
                }
            }
            .coordinateSpace(name: "field")
            .padding(.top, 110)
            .padding(.bottom, 90)

            if visible.isEmpty { emptyState }

            VStack {
                header
                Spacer()
                addButton
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingNew) {
            NewBubbleView(colorIndex: store.nextColorIndex, defaultScope: filter ?? .week) { store.add($0) }
        }
        .sheet(item: Binding(
            get: { openBubbleID.map { IdentifiedID(id: $0) } },
            set: { openBubbleID = $0?.id }
        )) { item in
            BubbleDetailView(store: store, bubbleID: item.id) { popped in
                pop(popped)
            }
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [Color(red: 0.07, green: 0.10, blue: 0.25), Color(red: 0.16, green: 0.28, blue: 0.52)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Bubbles")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                Spacer()
                if store.poppedCount > 0 {
                    Label("\(store.poppedCount) popped", systemImage: "sparkles")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.15), in: Capsule())
                }
            }
            .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    chip("All", selected: filter == nil) { filter = nil }
                    ForEach(BubbleScope.allCases) { scope in
                        chip(scope.title, selected: filter == scope) { filter = scope }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func chip(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: { withAnimation(.snappy) { action() } }) {
            Text(title)
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .foregroundStyle(selected ? Color(red: 0.1, green: 0.15, blue: 0.35) : .white)
                .background(selected ? Color.white : Color.white.opacity(0.15), in: Capsule())
        }
    }

    private var addButton: some View {
        Button {
            showingNew = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(
                    Circle().fill(
                        LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                )
                .shadow(color: .purple.opacity(0.6), radius: 12)
        }
        .padding(.bottom, 12)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "circle.dotted")
                .font(.system(size: 48))
            Text(filter == nil ? "No bubbles yet" : "No \(filter!.title.lowercased()) bubbles")
                .font(.system(.title3, design: .rounded).weight(.bold))
            Text("Tap + to blow one and fill it with goals")
                .font(.system(.subheadline, design: .rounded))
                .opacity(0.8)
        }
        .foregroundStyle(.white.opacity(0.85))
        .allowsHitTesting(false)
    }

    private func stepField(to now: Date, in bounds: CGRect) {
        let items = visible.map { bubble -> (id: UUID, radius: CGFloat, mood: FloatField.Mood) in
            (id: bubble.id, radius: bubble.scope.diameter / 2, mood: mood(for: bubble, at: now))
        }
        field.step(to: now, in: bounds, items: items)
    }

    private func mood(for bubble: Bubble, at now: Date) -> FloatField.Mood {
        if bubble.isComplete { return .rising }
        if bubble.isExpired(at: now) { return .sinking }
        return .normal
    }

    private func wobble(for bubble: Bubble, at now: Date) -> Double {
        let seed = Double(abs(bubble.id.hashValue % 1000)) / 1000 * 2 * .pi
        return now.timeIntervalSinceReferenceDate * 1.6 + seed
    }

    private func pop(_ bubble: Bubble) {
        if let pos = field.position(of: bubble.id) {
            let burst = Burst(position: pos, color: bubble.color)
            bursts.append(burst)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                bursts.removeAll { $0.id == burst.id }
            }
        }
        withAnimation { store.pop(bubble.id) }
    }
}

struct IdentifiedID: Identifiable {
    let id: UUID
}
