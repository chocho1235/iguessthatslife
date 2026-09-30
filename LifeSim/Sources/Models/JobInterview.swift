import Foundation

enum AnswerQuality {
    case good
    case mediocre
    case bad
    case unhinged
}

struct InterviewAnswer: Identifiable {
    let id = UUID()
    let text: String
    let quality: AnswerQuality
}

struct InterviewQuestion: Identifiable {
    let id = UUID()
    let prompt: String
    let options: [InterviewAnswer]
}

struct JobInterviewSession: Identifiable {
    let id = UUID()
    let job: Job
    let opener: [String]
    let questions: [InterviewQuestion]
}
