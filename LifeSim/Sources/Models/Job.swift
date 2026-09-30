import Foundation

struct Job: Identifiable, Hashable {
    let id: String
    let title: String
    let category: String
    let baseSalary: Int
    let requiresDegree: Bool
    let isPartTime: Bool
}
