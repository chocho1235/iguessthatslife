import Foundation

enum InterviewData {
    /// %job% is resolved to the job title when questions are drawn.
    static let bank: [(prompt: String, options: [(text: String, quality: AnswerQuality)])] = [
        (
            "A customer is yelling at you over something that isn't your fault. What do you do?",
            [
                ("Calmly apologize and try to solve the problem.", .good),
                ("Explain it's not your department, but help find someone who can.", .mediocre),
                ("Just walk away without saying anything.", .bad),
                ("Yell back louder to establish dominance.", .unhinged),
            ]
        ),
        (
            "Your shift at %job% ends in five minutes but there's still a line. What do you do?",
            [
                ("Stay a few extra minutes to help clear the line.", .good),
                ("Serve a couple more, then hand off to the next shift.", .mediocre),
                ("Leave right on the dot, line or no line.", .bad),
                ("Announce the store is closed and turn off the lights.", .unhinged),
            ]
        ),
        (
            "How do you handle a disagreement with a coworker?",
            [
                ("Talk it out privately and find common ground.", .good),
                ("Bring it up in the group chat so everyone can weigh in.", .mediocre),
                ("Avoid them for the rest of the week.", .bad),
                ("Challenge them to a thumb war to settle it.", .unhinged),
            ]
        ),
        (
            "What's your plan if you make a mistake at %job%?",
            [
                ("Own up to it immediately and fix it.", .good),
                ("Quietly fix it and hope nobody noticed.", .mediocre),
                ("Blame a coworker.", .bad),
                ("Deny everything, even with video evidence.", .unhinged),
            ]
        ),
        (
            "Why do you want to work at %job%?",
            [
                ("I think I'd genuinely be good at it and enjoy the work.", .good),
                ("The pay seems decent and it's close to home.", .mediocre),
                ("I don't really have a reason, I just applied everywhere.", .bad),
                ("I heard this is where legends are made.", .unhinged),
            ]
        ),
        (
            "A coworker keeps taking credit for your work. What now?",
            [
                ("Address it directly and calmly with them.", .good),
                ("Mention it to a manager privately.", .mediocre),
                ("Start slacking off out of spite.", .bad),
                ("Start a rumor to ruin their reputation.", .unhinged),
            ]
        ),
        (
            "How would you describe your work ethic at %job%?",
            [
                ("Reliable — I show up and do what's needed.", .good),
                ("Depends on the day, honestly.", .mediocre),
                ("I do the bare minimum to get by.", .bad),
                ("I work best under a threat of violence.", .unhinged),
            ]
        ),
        (
            "It's your first week at %job% and someone asks for help you're not trained for yet. What do you say?",
            [
                ("I'm not sure, but let me find someone who knows.", .good),
                ("I'll give it a try and hope for the best.", .mediocre),
                ("Not my problem.", .bad),
                ("I make something up with total confidence.", .unhinged),
            ]
        ),
    ]

    static func randomQuestions(count: Int, jobTitle: String) -> [InterviewQuestion] {
        Array(bank.shuffled().prefix(count)).map { entry in
            let options = entry.options.shuffled().map { option in
                InterviewAnswer(text: option.text.replacingOccurrences(of: "%job%", with: jobTitle), quality: option.quality)
            }
            return InterviewQuestion(
                prompt: entry.prompt.replacingOccurrences(of: "%job%", with: jobTitle),
                options: options
            )
        }
    }
}
