import Foundation

enum MigrationData {
    /// Richer destinations cost more to relocate to and get a visa for.
    static func migrationCost(for profile: CountryProfile) -> Int {
        Int(6000 + 10000 * profile.salaryMultiplier)
    }

    static func quizSession(for country: String) -> MigrationQuizSession? {
        guard let profile = CountryData.profiles[country] else { return nil }
        let others = CountryData.profiles.filter { $0.key != country }.map(\.value)
        guard others.count >= 3 else { return nil }

        func question(_ prompt: String, correct: String, pick: (CountryProfile) -> String) -> MigrationQuizQuestion {
            var distractors: [String] = []
            var pool = others.shuffled()
            while distractors.count < 3, !pool.isEmpty {
                let candidate = pick(pool.removeLast())
                if candidate != correct && !distractors.contains(candidate) {
                    distractors.append(candidate)
                }
            }
            var options = distractors + [correct]
            options.shuffle()
            return MigrationQuizQuestion(prompt: prompt, options: options, correctIndex: options.firstIndex(of: correct) ?? 0)
        }

        let allQuestions = [
            question("What is the capital of \(country)?", correct: profile.capital, pick: \.capital),
            question("What language is primarily spoken in \(country)?", correct: profile.language, pick: \.language),
            question("What currency is used in \(country)?", correct: profile.currency, pick: \.currency),
            question("\(country) is famous for which landmark?", correct: profile.landmark, pick: \.landmark),
        ].shuffled()

        let cost = migrationCost(for: profile)
        return MigrationQuizSession(destinationCountry: country, cost: cost, questions: Array(allQuestions.prefix(3)))
    }
}
