import Foundation

struct Friend: Identifiable {
    let id = UUID()
    var name: String
    var gender: Gender
    var relationship: Int
    var volatility: Int

    init(name: String, gender: Gender, relationship: Int, volatility: Int = Int.random(in: 0...100)) {
        self.name = name
        self.gender = gender
        self.relationship = relationship
        self.volatility = volatility
    }

    mutating func adjustRelationship(_ delta: Int) {
        relationship = min(100, max(0, relationship + delta))
    }
}

enum PersonRef: Hashable {
    case family(UUID)
    case friend(UUID)
    /// A one-off NPC with no lasting relationship state — a gang recruiter,
    /// a stranger offering a job, etc.
    case stranger
}

enum SocialEventKind {
    case moneyRequest
    case fightBackup
    case familyEmergency
    case hangoutInvite
    case riskyScheme
    case coverStory
    case gangRecruitment
    case jobOffer
}

struct SocialEvent: Identifiable {
    let id = UUID()
    let kind: SocialEventKind
    let actorRef: PersonRef
    let actorName: String
    let actorLabel: String
    let actorGender: Gender
    let targetRef: PersonRef?
    let targetName: String?
    let amount: Int
    let customTitle: String?
    let customMessage: String?
    let customAcceptTitle: String?
    let customDeclineTitle: String?

    init(
        kind: SocialEventKind,
        actorRef: PersonRef,
        actorName: String,
        actorLabel: String,
        actorGender: Gender = .male,
        targetRef: PersonRef?,
        targetName: String?,
        amount: Int,
        customTitle: String? = nil,
        customMessage: String? = nil,
        customAcceptTitle: String? = nil,
        customDeclineTitle: String? = nil
    ) {
        self.kind = kind
        self.actorRef = actorRef
        self.actorName = actorName
        self.actorLabel = actorLabel
        self.actorGender = actorGender
        self.targetRef = targetRef
        self.targetName = targetName
        self.amount = amount
        self.customTitle = customTitle
        self.customMessage = customMessage
        self.customAcceptTitle = customAcceptTitle
        self.customDeclineTitle = customDeclineTitle
    }

    var title: String {
        if let customTitle { return customTitle }
        switch kind {
        case .moneyRequest:
            return "\(actorName) needs cash"
        case .fightBackup:
            return "\(actorName) wants backup"
        case .familyEmergency:
            return "\(actorName) has an emergency"
        case .hangoutInvite:
            return "\(actorName) wants to hang out"
        case .riskyScheme:
            return "\(actorName) has a wild idea"
        case .coverStory:
            return "\(actorName) needs you to cover"
        case .gangRecruitment:
            return "\(actorName) wants you to join up"
        case .jobOffer:
            return "\(actorName) has a job for you"
        }
    }

    var message: String {
        if let customMessage { return customMessage }
        switch kind {
        case .moneyRequest:
            return "\(actorName) asked you for $\(amount). Helping could bring you closer, but saying no might hurt the relationship."
        case .fightBackup:
            let target = targetName ?? "someone they know"
            return "\(actorName) wants you to help them confront \(target). It could prove loyalty, but fights can go badly."
        case .familyEmergency:
            return "Your \(actorLabel.lowercased()), \(actorName), needs $\(amount) for an urgent problem. They will remember what you do."
        case .hangoutInvite:
            return "\(actorName) invited you out for the day. It could be exactly what you need, or it could pull you away from everything else."
        case .riskyScheme:
            return "\(actorName) has a risky plan and wants you in. It might pay off, but this is not exactly a sensible afternoon."
        case .coverStory:
            let target = targetName ?? "someone else"
            return "\(actorName) wants you to lie to \(target) for them. Loyalty might help your friendship, but it could make things messy."
        case .gangRecruitment:
            return "\(actorName) wants you in their crew. They don't take rejection well — saying no could get ugly."
        case .jobOffer:
            return "\(actorName) knows of an opening and thinks you'd be a good fit. No interview, no questions asked."
        }
    }

    var acceptTitle: String {
        if let customAcceptTitle { return customAcceptTitle }
        switch kind {
        case .moneyRequest, .familyEmergency:
            return "Give $\(amount)"
        case .fightBackup:
            return "Back Them Up"
        case .hangoutInvite:
            return "Go With Them"
        case .riskyScheme:
            return "Do It"
        case .coverStory:
            return "Cover For Them"
        case .gangRecruitment:
            return "Join Up"
        case .jobOffer:
            return "Take the Job"
        }
    }

    var declineTitle: String {
        if let customDeclineTitle { return customDeclineTitle }
        switch kind {
        case .moneyRequest, .familyEmergency:
            return "Say No"
        case .fightBackup:
            return "Stay Out"
        case .hangoutInvite:
            return "Not Today"
        case .riskyScheme:
            return "Bad Idea"
        case .coverStory:
            return "Tell Them No"
        case .gangRecruitment:
            return "Refuse"
        case .jobOffer:
            return "Pass"
        }
    }
}
