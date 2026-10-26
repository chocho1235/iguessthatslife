import SwiftUI

enum BubbleScope: String, Codable, CaseIterable, Identifiable {
    case day, week, month, year

    var id: String { rawValue }

    var title: String {
        switch self {
        case .day: return "Day"
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        }
    }

    var calendarComponent: Calendar.Component {
        switch self {
        case .day: return .day
        case .week: return .weekOfYear
        case .month: return .month
        case .year: return .year
        }
    }

    // Bigger time spans get bigger bubbles.
    var diameter: CGFloat {
        switch self {
        case .day: return 96
        case .week: return 118
        case .month: return 140
        case .year: return 166
        }
    }
}

struct Goal: Identifiable, Codable, Equatable {
    var id = UUID()
    var text: String
    var isDone = false
}

struct Bubble: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var scope: BubbleScope
    var periodStart: Date
    var goals: [Goal]
    var colorIndex: Int
    var createdAt = Date()

    init(title: String, scope: BubbleScope, containing date: Date, goals: [Goal], colorIndex: Int) {
        self.title = title
        self.scope = scope
        self.periodStart = Bubble.startOfPeriod(scope, containing: date)
        self.goals = goals
        self.colorIndex = colorIndex
    }

    static func startOfPeriod(_ scope: BubbleScope, containing date: Date) -> Date {
        Calendar.current.dateInterval(of: scope.calendarComponent, for: date)?.start
            ?? Calendar.current.startOfDay(for: date)
    }

    var period: DateInterval {
        Calendar.current.dateInterval(of: scope.calendarComponent, for: periodStart)
            ?? DateInterval(start: periodStart, duration: 86_400)
    }

    var deadline: Date { period.end }

    var doneCount: Int { goals.filter(\.isDone).count }

    var progress: Double {
        goals.isEmpty ? 0 : Double(doneCount) / Double(goals.count)
    }

    var isComplete: Bool { !goals.isEmpty && doneCount == goals.count }

    func isExpired(at now: Date = Date()) -> Bool { now >= deadline && !isComplete }

    func hasStarted(at now: Date = Date()) -> Bool { now >= period.start }

    var color: Color { BubblePalette.color(colorIndex) }

    var periodLabel: String {
        let start = period.start
        let f = DateFormatter()
        switch scope {
        case .day:
            f.dateFormat = "EEE d MMM"
            return f.string(from: start)
        case .week:
            f.dateFormat = "d MMM"
            let lastDay = Calendar.current.date(byAdding: .day, value: -1, to: period.end) ?? start
            return "\(f.string(from: start)) to \(f.string(from: lastDay))"
        case .month:
            f.dateFormat = "MMMM yyyy"
            return f.string(from: start)
        case .year:
            f.dateFormat = "yyyy"
            return f.string(from: start)
        }
    }

    func timeLeftLabel(at now: Date = Date()) -> String {
        if isComplete { return "Done!" }
        if !hasStarted(at: now) {
            return "Starts in " + Bubble.shortDuration(period.start.timeIntervalSince(now))
        }
        let left = deadline.timeIntervalSince(now)
        if left <= 0 { return "Time's up" }
        return Bubble.shortDuration(left) + " left"
    }

    static func shortDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds / 60)
        let hours = minutes / 60
        let days = hours / 24
        if days >= 60 { return "\(days / 30)mo" }
        if days >= 14 { return "\(days / 7)w" }
        if days >= 1 { return "\(days)d" }
        if hours >= 1 { return "\(hours)h" }
        return "\(max(minutes, 1))m"
    }
}

enum BubblePalette {
    static let colors: [Color] = [
        Color(red: 0.36, green: 0.62, blue: 1.00),
        Color(red: 1.00, green: 0.45, blue: 0.62),
        Color(red: 0.45, green: 0.85, blue: 0.62),
        Color(red: 1.00, green: 0.72, blue: 0.30),
        Color(red: 0.66, green: 0.50, blue: 1.00),
        Color(red: 0.30, green: 0.85, blue: 0.90),
        Color(red: 1.00, green: 0.55, blue: 0.40),
    ]

    static func color(_ index: Int) -> Color {
        colors[((index % colors.count) + colors.count) % colors.count]
    }
}
