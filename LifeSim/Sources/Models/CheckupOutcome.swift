import Foundation

struct DiagnosedConditionInfo: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let service: DoctorService
}

struct CheckupOutcome: Identifiable {
    let id = UUID()
    let dialogue: [String]
    let diagnosedConditions: [DiagnosedConditionInfo]
}
