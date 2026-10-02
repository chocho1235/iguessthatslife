import Foundation

struct Job: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let category: String
    let baseSalary: Int
    let requiresDegree: Bool
    let isPartTime: Bool
    /// Some jobs only make sense in economies above or below a certain
    /// wealth tier (a country's `salaryMultiplier`) — high-end tech/finance
    /// roles need a developed economy, while some labor jobs only exist
    /// where that higher-tier work hasn't taken over.
    let minSalaryMultiplier: Double
    let maxSalaryMultiplier: Double

    init(id: String, title: String, category: String, baseSalary: Int, requiresDegree: Bool, isPartTime: Bool, minSalaryMultiplier: Double = 0, maxSalaryMultiplier: Double = .infinity) {
        self.id = id
        self.title = title
        self.category = category
        self.baseSalary = baseSalary
        self.requiresDegree = requiresDegree
        self.isPartTime = isPartTime
        self.minSalaryMultiplier = minSalaryMultiplier
        self.maxSalaryMultiplier = maxSalaryMultiplier
    }
}
