import Foundation

@MainActor
final class GameViewModel: ObservableObject {
    @Published var character: Character?
    @Published var yearLog: [LogEntry] = []
    @Published var isGameOver: Bool = false

    private static let checkupOpeners: [[String]] = [
        ["Hi %name%, come on in — let's take a look at you.", "Alright, let me check your vitals..."],
        ["Good to see you, %name%. Hop up on the table.", "Let's see what's going on..."],
        ["%name%! Right on time. Let's get started.", "I'm just going to run a few quick checks..."],
        ["Take a seat, %name% — this won't take long.", "Let me listen to your heart and lungs..."],
        ["Welcome back, %name%. How have you been feeling?", "Let's find out what's really going on..."],
    ]

    private static let interviewOpeners: [[String]] = [
        ["Thanks for coming in, %name%. Tell me a bit about yourself.", "Let me take a look at your application..."],
        ["Nice to meet you, %name%. Have a seat.", "So, why do you want to work here?"],
        ["%name%! Glad you could make it.", "Give me just a moment to review your resume..."],
        ["Welcome in, %name%. This won't take long.", "Let's see if you're a good fit..."],
    ]

    func startNewLife() {
        let gender: Gender = Bool.random() ? .male : .female
        let firstName = NameData.randomFirstName(for: gender)
        let lastName = NameData.randomLastName()
        let country = NameData.randomCountry()

        var family: [FamilyMember] = [
            FamilyMember(name: "\(NameData.randomFirstName(for: .female)) \(lastName)", relation: .mother, relationship: Int.random(in: 60...95)),
            FamilyMember(name: "\(NameData.randomFirstName(for: .male)) \(lastName)", relation: .father, relationship: Int.random(in: 60...95)),
        ]
        if Bool.random() {
            let siblingGender: Gender = Bool.random() ? .male : .female
            family.append(
                FamilyMember(
                    name: "\(NameData.randomFirstName(for: siblingGender)) \(lastName)",
                    relation: siblingGender == .male ? .brother : .sister,
                    relationship: Int.random(in: 50...90)
                )
            )
        }

        character = Character(
            firstName: firstName,
            lastName: lastName,
            gender: gender,
            country: country,
            age: 0,
            stats: Stats.random(),
            family: family,
            cash: Int.random(in: 20...50)
        )
        yearLog = [LogEntry(text: "You were born in \(country) to \(family[0].name) and \(family[1].name).", isAlert: false)]
        isGameOver = false
    }

    func ageUp() {
        guard var current = character, current.isAlive else { return }
        current.age += 1

        let stage = current.stage
        let eventCount = Int.random(in: 1...3)
        var log: [LogEntry] = []

        let allowance = Int.random(in: 5...25)
        current.cash += allowance
        log.append(LogEntry(text: "You received $\(allowance).", isAlert: false))

        for event in EventData.randomEvents(for: stage, count: eventCount) {
            current.stats.adjust(
                health: event.healthDelta,
                happiness: event.happinessDelta,
                smarts: event.smartsDelta,
                looks: event.looksDelta
            )
            if event.relationshipDelta != 0, !current.family.isEmpty {
                let index = Int.random(in: 0..<current.family.count)
                current.family[index].adjustRelationship(event.relationshipDelta)
            }
            if event.cashDelta != 0 {
                current.cash = max(0, current.cash + event.cashDelta)
            }
            if let conditionID = event.grantsConditionID {
                grantCondition(&current, id: conditionID)
            }

            var entry = event.text(current)
            if event.cashDelta > 0 {
                entry += " (+$\(event.cashDelta))"
            } else if event.cashDelta < 0 {
                entry += " (-$\(abs(event.cashDelta)))"
            }
            let isAlert = event.healthDelta < 0 || event.cashDelta < 0 || event.relationshipDelta < 0 || event.grantsConditionID != nil
            log.append(LogEntry(text: entry, isAlert: isAlert))
        }

        handleFriends(&current, log: &log)
        handleConditions(&current, log: &log)
        rollForVision(&current, log: &log)
        handleCareer(&current, log: &log)
        applyNaturalDrift(&current)
        checkForDeath(&current, log: &log)

        character = current
        yearLog = log
        if !current.isAlive {
            isGameOver = true
        }
    }

    func purchase(_ accessory: Accessory) {
        guard var current = character,
              current.cash >= accessory.price,
              !current.ownedAccessoryIDs.contains(accessory.id) else { return }
        current.cash -= accessory.price
        current.ownedAccessoryIDs.insert(accessory.id)
        current.equippedAccessoryIDs[accessory.slot] = accessory.id
        character = current
    }

    func equip(_ accessory: Accessory) {
        guard var current = character, current.ownedAccessoryIDs.contains(accessory.id) else { return }
        current.equippedAccessoryIDs[accessory.slot] = accessory.id
        character = current
    }

    func unequip(slot: AccessorySlot) {
        guard var current = character else { return }
        current.equippedAccessoryIDs[slot] = nil
        character = current
    }

    @discardableResult
    func spendTime(with ref: PersonRef) -> String {
        guard var current = character else { return "" }
        let gain = Int.random(in: 4...10)
        adjustRelationship(&current, ref: ref, by: gain)
        current.stats.adjust(happiness: 2)
        character = current
        return "You spent quality time together. Relationship +\(gain)."
    }

    @discardableResult
    func giveGift(with ref: PersonRef, cost: Int = 15) -> String {
        guard var current = character else { return "" }
        guard current.cash >= cost else { return "You don't have enough cash for a gift." }
        current.cash -= cost
        let gain = Int.random(in: 12...20)
        adjustRelationship(&current, ref: ref, by: gain)
        character = current
        return "You gave a $\(cost) gift. Relationship +\(gain)."
    }

    @discardableResult
    func askForMoney(from ref: PersonRef) -> String {
        guard var current = character else { return "" }
        let relationship = relationshipValue(current, ref: ref)
        if relationship >= 50 {
            let amount = Int.random(in: 5...25)
            current.cash += amount
            character = current
            return "They happily gave you $\(amount)."
        } else {
            character = current
            return "They said no — you're not close enough yet."
        }
    }

    @discardableResult
    func prank(_ ref: PersonRef) -> String {
        guard var current = character else { return "" }
        if Bool.random() {
            let gain = Int.random(in: 2...8)
            adjustRelationship(&current, ref: ref, by: gain)
            current.stats.adjust(happiness: 5)
            character = current
            return "Your prank landed perfectly! Everyone had a good laugh. Relationship +\(gain)."
        } else {
            let loss = Int.random(in: 5...12)
            adjustRelationship(&current, ref: ref, by: -loss)
            character = current
            return "Your prank backfired badly. Relationship -\(loss)."
        }
    }

    @discardableResult
    func argue(with ref: PersonRef) -> String {
        guard var current = character else { return "" }
        let loss = Int.random(in: 15...25)
        adjustRelationship(&current, ref: ref, by: -loss)
        current.stats.adjust(happiness: -Int.random(in: 2...6))
        character = current
        return "You got into a heated argument. Relationship -\(loss)."
    }

    @discardableResult
    func steal(from ref: PersonRef) -> String {
        guard var current = character else { return "" }
        if Double.random(in: 0...1) < 0.4 {
            let loss = Int.random(in: 25...40)
            adjustRelationship(&current, ref: ref, by: -loss)
            current.stats.adjust(happiness: -Int.random(in: 5...15))
            if Double.random(in: 0...1) < 0.15, current.scars < 3 {
                current.scars += 1
            }
            character = current
            return "You got caught red-handed! They're furious with you. Relationship -\(loss)."
        } else {
            let amount = Int.random(in: 5...30)
            current.cash += amount
            let loss = Int.random(in: 5...10)
            adjustRelationship(&current, ref: ref, by: -loss)
            character = current
            return "You secretly took $\(amount) without getting caught, but you feel a little guilty."
        }
    }

    func performCheckup() -> CheckupOutcome {
        guard var current = character else {
            return CheckupOutcome(dialogue: [], diagnosedConditions: [])
        }
        guard current.cash >= DoctorService.checkup.cost else {
            return CheckupOutcome(dialogue: ["You can't afford a checkup right now."], diagnosedConditions: [])
        }
        current.cash -= DoctorService.checkup.cost

        let opening = Self.checkupOpeners.randomElement()!.map { line in
            line.replacingOccurrences(of: "%name%", with: current.firstName)
        }

        var diagnosed: [DiagnosedConditionInfo] = []
        for index in current.conditions.indices where !current.conditions[index].isDiagnosed {
            current.conditions[index].isDiagnosed = true
            if let condition = ConditionData.byID[current.conditions[index].conditionID] {
                diagnosed.append(DiagnosedConditionInfo(name: condition.name, service: condition.severity.requiredService))
            }
        }

        if diagnosed.isEmpty {
            let heal = Int.random(in: 3...8)
            current.stats.adjust(health: heal)
        }

        character = current
        return CheckupOutcome(dialogue: opening, diagnosedConditions: diagnosed)
    }

    @discardableResult
    func treat(_ activeID: UUID) -> String {
        guard var current = character,
              let index = current.conditions.firstIndex(where: { $0.id == activeID }),
              current.conditions[index].isDiagnosed,
              let condition = ConditionData.byID[current.conditions[index].conditionID] else { return "" }
        guard !condition.requiresGlasses else { return "This isn't fixed by treatment — try a pair of glasses from the Shop." }
        let cost = condition.severity.requiredService.cost
        guard current.cash >= cost else { return "You can't afford treatment for this right now." }
        current.cash -= cost
        current.conditions.remove(at: index)
        current.stats.adjust(health: Int.random(in: 5...15))
        character = current
        return "\(condition.name) treated successfully!"
    }

    @discardableResult
    func treatAll() -> String {
        guard var current = character else { return "" }
        let treatableIndices = current.conditions.indices.filter { index in
            let active = current.conditions[index]
            guard active.isDiagnosed, let condition = ConditionData.byID[active.conditionID] else { return false }
            return !condition.requiresGlasses
        }
        guard !treatableIndices.isEmpty else { return "" }

        let totalCost = treatableIndices.reduce(0) { sum, index in
            sum + (ConditionData.byID[current.conditions[index].conditionID]?.severity.requiredService.cost ?? 0)
        }
        guard current.cash >= totalCost else { return "You can't afford to treat everything ($\(totalCost))." }

        let treatedIDs = Set(treatableIndices.map { current.conditions[$0].id })
        let names = treatableIndices.compactMap { ConditionData.byID[current.conditions[$0].conditionID]?.name }
        current.cash -= totalCost
        current.conditions.removeAll { treatedIDs.contains($0.id) }
        current.stats.adjust(health: Int.random(in: 5...15))
        character = current
        return "Treated: \(names.joined(separator: ", "))."
    }

    private func grantCondition(_ character: inout Character, id: String) {
        guard let condition = ConditionData.byID[id] else { return }
        guard !character.conditions.contains(where: { $0.conditionID == id }) else { return }
        guard character.conditions.count < 2 else { return }
        character.conditions.append(ActiveCondition(conditionID: id))

        // Severe conditions mean surgery, and surgery leaves a mark.
        if condition.severity == .severe, character.scars < 3 {
            character.scars += 1
        }
    }

    private func handleConditions(_ character: inout Character, log: inout [LogEntry]) {
        var remaining: [ActiveCondition] = []
        for var active in character.conditions {
            guard let condition = ConditionData.byID[active.conditionID] else { continue }
            active.yearsAfflicted += 1

            if condition.requiresGlasses {
                // Vision only bothers happiness while uncorrected, and never
                // clears on its own — only wearing glasses fixes it.
                if !character.isWearingCorrectiveGlasses {
                    character.stats.adjust(happiness: -condition.happinessDrain)
                }
                remaining.append(active)
                continue
            }

            character.stats.adjust(health: -condition.healthDrain, happiness: -condition.happinessDrain)
            if Double.random(in: 0...1) < condition.naturalRecoveryChance {
                let description = active.isDiagnosed ? condition.name : "whatever was troubling them"
                log.append(LogEntry(text: "\(character.firstName) recovered from \(description).", isAlert: false))
            } else {
                remaining.append(active)
            }
        }
        character.conditions = remaining

        if character.conditions.count < 2, Double.random(in: 0...1) < 0.08,
           let condition = ConditionData.randomCondition(for: character.stage, excluding: Set(character.conditions.map { $0.conditionID }).union(["poor_vision"])) {
            character.conditions.append(ActiveCondition(conditionID: condition.id))
            log.append(LogEntry(text: "\(character.firstName) hasn't been feeling right lately — a checkup might be wise.", isAlert: true))
        }
    }

    /// Vision risk climbs with age, independent of the general illness roll,
    /// so glasses become an increasingly likely need later in life.
    private func rollForVision(_ character: inout Character, log: inout [LogEntry]) {
        guard !character.conditions.contains(where: { $0.conditionID == "poor_vision" }) else { return }
        guard character.conditions.count < 2 else { return }

        let chance: Double
        switch character.age {
        case 0..<13: chance = 0
        case 13..<18: chance = 0.01
        case 18..<40: chance = 0.02
        case 40..<60: chance = 0.05
        case 60..<75: chance = 0.09
        default: chance = 0.14
        }

        guard chance > 0, Double.random(in: 0...1) < chance else { return }
        character.conditions.append(ActiveCondition(conditionID: "poor_vision"))
        log.append(LogEntry(text: "\(character.firstName) has been squinting a lot lately — their eyesight might be going.", isAlert: true))
    }

    @discardableResult
    func enrollInUniversity(_ universityName: String) -> String {
        guard var current = character else { return "" }
        guard current.educationLevel != .university else { return "Already a graduate." }
        guard current.stats.smarts >= 50 else { return "Not smart enough to get in yet — keep studying." }
        let tuition = Int(Double(3000) * CountryData.profile(for: current.country).salaryMultiplier)
        guard current.cash >= tuition else { return "You can't afford tuition ($\(tuition))." }
        current.cash -= tuition
        current.educationLevel = .university
        current.universityName = universityName
        current.stats.adjust(happiness: 5, smarts: 15)
        character = current
        return "Congratulations! You graduated from \(universityName)."
    }

    func startInterview(for job: Job) -> JobInterviewSession? {
        guard let current = character else { return nil }
        guard !job.requiresDegree || current.educationLevel == .university else { return nil }

        let opener = Self.interviewOpeners.randomElement()!.map { line in
            line.replacingOccurrences(of: "%name%", with: current.firstName)
        }
        let questions = InterviewData.randomQuestions(count: 2, jobTitle: job.title)
        return JobInterviewSession(job: job, opener: opener, questions: questions)
    }

    func resolveInterview(_ session: JobInterviewSession, answers: [AnswerQuality]) -> JobApplicationOutcome {
        guard var current = character else {
            return JobApplicationOutcome(result: .rejected, job: session.job)
        }

        // Picking an unhinged answer doesn't guarantee disaster, but it's the
        // only way an interview can blow up into a fight.
        if answers.contains(.unhinged), Double.random(in: 0...1) < 0.25 {
            current.stats.adjust(health: -Int.random(in: 3...8), happiness: -Int.random(in: 5...12))
            if Double.random(in: 0...1) < 0.4, current.scars < 3 {
                current.scars += 1
            }
            character = current
            return JobApplicationOutcome(result: .fight, job: session.job)
        }

        let score = answers.reduce(0) { total, quality in
            switch quality {
            case .good: return total + 2
            case .mediocre: return total + 1
            case .bad, .unhinged: return total
            }
        }
        let maxScore = max(1, session.questions.count * 2)
        let answerRatio = Double(score) / Double(maxScore)
        let successChance = min(0.95, max(0.05, 0.2 + answerRatio * 0.55 + Double(current.stats.smarts) / 400.0))

        let hired = Double.random(in: 0...1) < successChance
        if hired {
            current.job = session.job
            current.yearsAtJob = 0
        }
        character = current
        return JobApplicationOutcome(result: hired ? .hired : .rejected, job: session.job)
    }

    @discardableResult
    func quitJob() -> String {
        guard var current = character, let job = current.job else { return "" }
        current.job = nil
        current.yearsAtJob = 0
        character = current
        return "You quit your job as \(job.title)."
    }

    private func handleCareer(_ character: inout Character, log: inout [LogEntry]) {
        guard let job = character.job else { return }

        if job.isPartTime != (character.stage == .teen) {
            character.job = nil
            character.yearsAtJob = 0
            log.append(LogEntry(text: "\(character.firstName) moved on from their job as \(job.title).", isAlert: false))
            return
        }

        character.yearsAtJob += 1
        let multiplier = CountryData.profile(for: character.country).salaryMultiplier
        let variance = Double.random(in: 0.9...1.1)
        let pay = max(0, Int(Double(job.baseSalary) * multiplier * variance))
        character.cash += pay
        log.append(LogEntry(text: "\(character.firstName) earned $\(pay) working as \(job.title).", isAlert: false))

        if character.yearsAtJob % 3 == 0 {
            let raised = Job(id: job.id, title: job.title, category: job.category, baseSalary: Int(Double(job.baseSalary) * 1.08), requiresDegree: job.requiresDegree, isPartTime: job.isPartTime)
            character.job = raised
            log.append(LogEntry(text: "\(character.firstName) got a raise at work!", isAlert: false))
        }

        if character.stats.happiness < 25, Double.random(in: 0...1) < 0.1 {
            log.append(LogEntry(text: "\(character.firstName) was let go from their job as \(job.title) after a rough patch.", isAlert: true))
            character.job = nil
            character.yearsAtJob = 0
        }
    }

    private func relationshipValue(_ character: Character, ref: PersonRef) -> Int {
        switch ref {
        case .family(let id):
            return character.family.first(where: { $0.id == id })?.relationship ?? 0
        case .friend(let id):
            return character.friends.first(where: { $0.id == id })?.relationship ?? 0
        }
    }

    private func adjustRelationship(_ character: inout Character, ref: PersonRef, by delta: Int) {
        switch ref {
        case .family(let id):
            if let index = character.family.firstIndex(where: { $0.id == id }) {
                character.family[index].adjustRelationship(delta)
            }
        case .friend(let id):
            if let index = character.friends.firstIndex(where: { $0.id == id }) {
                character.friends[index].adjustRelationship(delta)
            }
        }
    }

    private func handleFriends(_ character: inout Character, log: inout [LogEntry]) {
        var remaining: [Friend] = []
        for var friend in character.friends {
            friend.adjustRelationship(Int.random(in: -3...5))
            if friend.relationship <= 0 || Double.random(in: 0...1) < 0.05 {
                log.append(LogEntry(text: "You and \(friend.name) drifted apart and are no longer friends.", isAlert: true))
            } else {
                remaining.append(friend)
            }
        }
        character.friends = remaining

        if character.stage != .infant, character.friends.count < 5, Double.random(in: 0...1) < 0.25 {
            let gender: Gender = Bool.random() ? .male : .female
            let name = "\(NameData.randomFirstName(for: gender)) \(NameData.randomLastName())"
            character.friends.append(Friend(name: name, gender: gender, relationship: Int.random(in: 40...70)))
            log.append(LogEntry(text: "You made a new friend, \(name)!", isAlert: false))
        }
    }

    private func applyNaturalDrift(_ character: inout Character) {
        // The body naturally recovers in youth and middle age; only real
        // decline sets in once someone is elderly. This keeps a run of bad
        // event rolls from being an automatic early death sentence.
        switch character.age {
        case 0...50: character.stats.adjust(health: Int.random(in: 1...4))
        case 51...65: character.stats.adjust(health: Int.random(in: -1...2))
        default: character.stats.adjust(health: -Int.random(in: 1...4))
        }
        if character.age > 40 {
            character.stats.adjust(looks: -Int.random(in: 0...2))
        }
    }

    private func checkForDeath(_ character: inout Character, log: inout [LogEntry]) {
        if character.stats.health <= 0 {
            if Double.random(in: 0...1) < 0.7 {
                character.stats.adjust(health: Int.random(in: 12...25))
                log.append(LogEntry(text: "\(character.firstName) was rushed to the hospital in critical condition, but pulled through.", isAlert: true))
            } else {
                character.isAlive = false
                character.causeOfDeath = determineCauseOfDeath(character)
                log.append(LogEntry(text: "\(character.firstName)'s health gave out. They passed away from \(character.causeOfDeath ?? "unknown causes") at age \(character.age).", isAlert: true))
            }
            return
        }

        var deathChance: Double
        switch character.age {
        case 0..<60: deathChance = 0.001
        case 60..<75: deathChance = 0.01
        case 75..<85: deathChance = 0.04
        case 85..<95: deathChance = 0.12
        case 95..<105: deathChance = 0.30
        default: deathChance = 0.55
        }

        let severeConditions = character.conditions.filter { ConditionData.byID[$0.conditionID]?.severity == .severe }.count
        deathChance += Double(severeConditions) * 0.04

        if Double.random(in: 0...1) < deathChance {
            character.isAlive = false
            character.causeOfDeath = determineCauseOfDeath(character)
            log.append(LogEntry(text: "\(character.firstName) passed away peacefully at age \(character.age), from \(character.causeOfDeath ?? "natural causes").", isAlert: true))
        }
    }

    /// Ties the cause of death to what was actually afflicting the character
    /// rather than a random flavor string, so the ending reflects the run.
    private func determineCauseOfDeath(_ character: Character) -> String {
        let conditionNames = character.conditions.compactMap { ConditionData.byID[$0.conditionID]?.name }
        switch conditionNames.count {
        case 0:
            return EventData.deathCauses.randomElement() ?? "natural causes"
        case 1:
            return conditionNames[0]
        default:
            return "complications from \(conditionNames.joined(separator: ", "))"
        }
    }
}
