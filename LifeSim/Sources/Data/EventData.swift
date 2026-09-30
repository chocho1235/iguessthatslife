import Foundation

enum EventData {
    static let pool: [LifeEvent] = [
        // Infant
        LifeEvent(stages: [.infant], happiness: 4, text: { c in "\(c.firstName) took their first steps." }),
        LifeEvent(stages: [.infant], happiness: 3, looks: 2, text: { c in "\(c.firstName) said their first word." }),
        LifeEvent(stages: [.infant], grantsCondition: "infant_fever", text: { c in "\(c.firstName) came down with a bad fever." }),
        LifeEvent(stages: [.infant], happiness: 5, relationship: 4, text: { c in "The whole family gathered to celebrate \(c.firstName)'s birthday." }),
        LifeEvent(stages: [.infant], happiness: -3, text: { c in "\(c.firstName) wouldn't stop crying all night." }),
        LifeEvent(stages: [.infant], happiness: 4, relationship: 3, text: { c in "The family brought home a puppy, and \(c.firstName) is obsessed." }),
        LifeEvent(stages: [.infant], happiness: 3, text: { c in "\(c.firstName) learned to crawl and is now getting into everything." }),
        LifeEvent(stages: [.infant], looks: 2, text: { c in "\(c.firstName) got their first haircut." }),
        LifeEvent(stages: [.infant], happiness: -2, text: { c in "\(c.firstName) is teething and won't stop fussing." }),
        LifeEvent(stages: [.infant], happiness: 6, relationship: 5, text: { c in "\(c.firstName) said \"mama\" and \"dada\" for the first time, melting hearts." }),
        LifeEvent(stages: [.infant], grantsCondition: "minor_injury", text: { c in "\(c.firstName) tumbled down two stairs and is a bit banged up." }),

        // Child
        LifeEvent(stages: [.child], happiness: 2, smarts: 5, text: { c in "\(c.firstName) got straight A's on their report card." }),
        LifeEvent(stages: [.child], happiness: -2, smarts: -4, text: { c in "\(c.firstName) struggled to keep up in class." }),
        LifeEvent(stages: [.child], happiness: 6, relationship: 3, text: { c in "\(c.firstName) made a new best friend at school." }),
        LifeEvent(stages: [.child], happiness: -6, text: { c in "\(c.firstName) got bullied at recess." }),
        LifeEvent(stages: [.child], happiness: 3, looks: 3, text: { c in "\(c.firstName) won first place in a costume contest." }),
        LifeEvent(stages: [.child], grantsCondition: "broken_arm", text: { c in "\(c.firstName) fell off the monkey bars and is holding their arm funny." }),
        LifeEvent(stages: [.child], smarts: 4, text: { c in "\(c.firstName) discovered a love of reading." }),
        LifeEvent(stages: [.child], happiness: 5, relationship: 5, text: { c in "\(c.firstName) went on a family vacation to the beach." }),
        LifeEvent(stages: [.child], happiness: -4, relationship: -4, text: { c in "\(c.firstName) got into a big fight with a sibling." }),
        LifeEvent(stages: [.child], happiness: 3, smarts: 5, text: { c in "\(c.firstName) won the school spelling bee." }),
        LifeEvent(stages: [.child], happiness: 3, text: { c in "\(c.firstName) got a pet goldfish named after a superhero." }),
        LifeEvent(stages: [.child], happiness: -3, relationship: -3, cash: -20, text: { c in "\(c.firstName) broke a neighbor's window and their parents had to pay for it." }),
        LifeEvent(stages: [.child], happiness: -2, smarts: 3, text: { c in "\(c.firstName) started piano lessons and practices reluctantly." }),
        LifeEvent(stages: [.child], happiness: 4, cash: 5, text: { c in "\(c.firstName) lost their first tooth and got a visit from the tooth fairy." }),
        LifeEvent(stages: [.child], happiness: -5, text: { c in "\(c.firstName) got separated from the family at the mall for a terrifying twenty minutes." }),
        LifeEvent(stages: [.child], happiness: 5, text: { c in "\(c.firstName) built an epic blanket fort that took over the living room." }),
        LifeEvent(stages: [.child], grantsCondition: "stomach_bug", text: { c in "\(c.firstName) came home from school looking pale and queasy." }),
        LifeEvent(stages: [.child], happiness: 2, cash: 10, text: { c in "\(c.firstName) found some loose change in the couch cushions." }),
        LifeEvent(stages: [.child], grantsCondition: "mystery_rash", text: { c in "\(c.firstName) has developed a strange rash that won't go away." }),

        // Teen
        LifeEvent(stages: [.teen], happiness: 5, looks: 2, text: { c in "\(c.firstName) went to their first school dance." }),
        LifeEvent(stages: [.teen], happiness: -8, text: { c in "\(c.firstName) got dumped by their first crush." }),
        LifeEvent(stages: [.teen], smarts: 6, text: { c in "\(c.firstName) aced a difficult exam." }),
        LifeEvent(stages: [.teen], happiness: -3, smarts: -6, text: { c in "\(c.firstName) failed a class and had to retake it." }),
        LifeEvent(stages: [.teen], happiness: 6, relationship: 3, text: { c in "\(c.firstName) joined a sports team and loved it." }),
        LifeEvent(stages: [.teen], happiness: -5, grantsCondition: "whiplash", text: { c in "\(c.firstName) got into a car accident while learning to drive." }),
        LifeEvent(stages: [.teen], happiness: -6, relationship: -8, text: { c in "\(c.firstName) had a huge argument with their parents." }),
        LifeEvent(stages: [.teen], happiness: 3, looks: 4, text: { c in "\(c.firstName) had a growth spurt and a new sense of style." }),
        LifeEvent(stages: [.teen], happiness: 4, smarts: 5, text: { c in "\(c.firstName) got accepted into a great university." }),
        LifeEvent(stages: [.teen], happiness: -3, grantsCondition: "insomnia", text: { c in "\(c.firstName) started feeling the pressure of exams and stopped sleeping well." }),
        LifeEvent(stages: [.teen], happiness: 2, smarts: 3, text: { c in "\(c.firstName) got their driver's permit." }),
        LifeEvent(stages: [.teen], happiness: 5, looks: 3, text: { c in "\(c.firstName) started a garage band with some friends." }),
        LifeEvent(stages: [.teen], happiness: -4, smarts: -3, relationship: -3, text: { c in "\(c.firstName) got caught skipping class and had to call their parents." }),
        LifeEvent(stages: [.teen], happiness: 7, looks: 3, text: { c in "\(c.firstName) won the school talent show." }),
        LifeEvent(stages: [.teen], happiness: 1, cash: 60, text: { c in "\(c.firstName) got their first part-time job at a fast food joint." }),
        LifeEvent(stages: [.teen], happiness: -7, looks: -3, text: { c in "\(c.firstName) posted an embarrassing video that went viral for all the wrong reasons." }),
        LifeEvent(stages: [.teen], happiness: -2, looks: -3, text: { c in "\(c.firstName) is going through an awkward acne phase." }),
        LifeEvent(stages: [.teen], happiness: -6, relationship: -6, text: { c in "\(c.firstName) snuck out to a party and got grounded for a month." }),
        LifeEvent(stages: [.teen], happiness: 4, smarts: 6, text: { c in "\(c.firstName) aced the SATs." }),

        // Adult
        LifeEvent(stages: [.adult], happiness: 8, relationship: 5, text: { c in "\(c.firstName) fell in love for the first time." }),
        LifeEvent(stages: [.adult], happiness: -10, text: { c in "\(c.firstName) went through a painful breakup." }),
        LifeEvent(stages: [.adult], happiness: 3, smarts: 4, text: { c in "\(c.firstName) picked up a fascinating new hobby." }),
        LifeEvent(stages: [.adult], grantsCondition: "pulled_muscle", text: { c in "\(c.firstName) overdid it at the gym and is walking a little stiff." }),
        LifeEvent(stages: [.adult], health: 6, happiness: 4, text: { c in "\(c.firstName) started a healthy new exercise routine." }),
        LifeEvent(stages: [.adult], happiness: -4, grantsCondition: "insomnia", text: { c in "\(c.firstName) went through a stressful, sleepless month at work." }),
        LifeEvent(stages: [.adult], looks: -4, text: { c in "\(c.firstName) noticed the first signs of aging." }),
        LifeEvent(stages: [.adult], happiness: 5, relationship: 6, text: { c in "\(c.firstName) reconnected with an old friend." }),
        LifeEvent(stages: [.adult], grantsCondition: "fall_injury", text: { c in "\(c.firstName) took a nasty fall and had to be looked at." }),
        LifeEvent(stages: [.adult], happiness: 7, text: { c in "\(c.firstName) took a spontaneous trip abroad." }),
        LifeEvent(stages: [.adult], happiness: -3, smarts: -3, text: { c in "\(c.firstName) felt stuck in a rut." }),
        LifeEvent(stages: [.adult], happiness: 6, relationship: 4, text: { c in "\(c.firstName) had a heartfelt reconciliation with family." }),
        LifeEvent(stages: [.adult], happiness: 4, cash: 150, text: { c in "\(c.firstName) got a big promotion at work." }),
        LifeEvent(stages: [.adult], happiness: 5, relationship: 3, text: { c in "\(c.firstName) adopted a rescue dog." }),
        LifeEvent(stages: [.adult], happiness: -5, smarts: -2, text: { c in "\(c.firstName) is having a full-blown quarter-life crisis." }),
        LifeEvent(stages: [.adult], health: 5, happiness: 5, text: { c in "\(c.firstName) trained for months and finished a marathon." }),
        LifeEvent(stages: [.adult], grantsCondition: "food_poisoning", text: { c in "\(c.firstName) ate something from a sketchy food truck and immediately regretted it." }),
        LifeEvent(stages: [.adult], grantsCondition: "mystery_fatigue", text: { c in "\(c.firstName) has been inexplicably exhausted for weeks." }),
        LifeEvent(stages: [.adult], happiness: -4, cash: -100, text: { c in "\(c.firstName) lost money on a questionable cryptocurrency." }),
        LifeEvent(stages: [.adult], happiness: 6, cash: 200, text: { c in "\(c.firstName) won a modest prize in the lottery." }),
        LifeEvent(stages: [.adult], happiness: -3, cash: -80, grantsCondition: "minor_injury", text: { c in "\(c.firstName) got into a minor fender bender and had to pay for repairs." }),
        LifeEvent(stages: [.adult], health: 3, happiness: 4, text: { c in "\(c.firstName) started meditating and feels calmer." }),
        LifeEvent(stages: [.adult], happiness: 3, text: { c in "\(c.firstName) binge-watched an entire series in one weekend." }),
        LifeEvent(stages: [.adult], cash: -50, text: { c in "\(c.firstName) got slapped with a parking ticket." }),

        // Senior
        LifeEvent(stages: [.senior], grantsCondition: "arthritis", text: { c in "\(c.firstName)'s joints have been aching more than usual." }),
        LifeEvent(stages: [.senior], happiness: 6, relationship: 6, text: { c in "\(c.firstName) spent a wonderful afternoon with grandchildren." }),
        LifeEvent(stages: [.senior], happiness: 5, text: { c in "\(c.firstName) took up a relaxing new pastime like gardening." }),
        LifeEvent(stages: [.senior], grantsCondition: "pneumonia", text: { c in "\(c.firstName) had a health scare that required a hospital visit." }),
        LifeEvent(stages: [.senior], happiness: -6, text: { c in "\(c.firstName) has been feeling lonely lately." }),
        LifeEvent(stages: [.senior], smarts: -4, text: { c in "\(c.firstName) has noticed their memory isn't what it used to be." }),
        LifeEvent(stages: [.senior], happiness: 7, relationship: 5, text: { c in "\(c.firstName) reminisced with old friends about the good old days." }),
        LifeEvent(stages: [.senior], happiness: 5, looks: 3, text: { c in "\(c.firstName) took up painting and is surprisingly good at it." }),
        LifeEvent(stages: [.senior], happiness: 6, cash: -120, text: { c in "\(c.firstName) splurged on a relaxing cruise." }),
        LifeEvent(stages: [.senior], happiness: -3, smarts: -3, text: { c in "\(c.firstName) forgot several names at a family dinner and felt embarrassed." }),
        LifeEvent(stages: [.senior], happiness: 6, relationship: 4, text: { c in "\(c.firstName) became the neighborhood's favorite storyteller." }),
        LifeEvent(stages: [.senior], grantsCondition: "fall_injury", text: { c in "\(c.firstName) took a small fall and started using a cane just in case." }),
        LifeEvent(stages: [.senior], happiness: 5, text: { c in "\(c.firstName) reconnected with an old flame from decades ago." }),
        LifeEvent(stages: [.senior], happiness: 3, cash: 40, text: { c in "\(c.firstName) won at bingo night." }),
    ]

    static let deathCauses = [
        "a long battle with illness",
        "a heart attack",
        "a peaceful passing in their sleep",
        "a sudden stroke",
        "complications from old age",
        "a tragic accident",
    ]

    static func randomEvents(for stage: LifeStage, count: Int) -> [LifeEvent] {
        let candidates = pool.filter { $0.stages.contains(stage) }
        guard !candidates.isEmpty else { return [] }
        var weighted: [LifeEvent] = []
        for event in candidates {
            weighted.append(contentsOf: Array(repeating: event, count: event.weight))
        }
        var results: [LifeEvent] = []
        var used = Set<UUID>()
        var attempts = 0
        while results.count < count && used.count < candidates.count && attempts < 50 {
            attempts += 1
            if let event = weighted.randomElement(), !used.contains(event.id) {
                used.insert(event.id)
                results.append(event)
            }
        }
        return results
    }
}
