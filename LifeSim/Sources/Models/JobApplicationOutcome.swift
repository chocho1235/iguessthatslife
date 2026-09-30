import Foundation

enum ApplicationResult {
    case hired
    case rejected
    case fight
}

struct JobApplicationOutcome: Identifiable {
    let id = UUID()
    let result: ApplicationResult
    let job: Job
}
