import Foundation

struct MigrationQuizQuestion: Identifiable {
    let id = UUID()
    let prompt: String
    let options: [String]
    let correctIndex: Int
}

struct MigrationQuizSession: Identifiable {
    let id = UUID()
    let destinationCountry: String
    let cost: Int
    let questions: [MigrationQuizQuestion]
}

struct MigrationOutcome: Identifiable {
    let id = UUID()
    let approved: Bool
    let destinationCountry: String
    let amountCharged: Int
    let correctCount: Int
    let totalQuestions: Int
    /// Extra flavor text for special cases — a border bust or a background
    /// check rejection — shown instead of the plain quiz-score explanation.
    var note: String? = nil
}
