import SwiftUI

enum CareerData {
    static let all: [CareerTrack] = [army, police, medicine, law, fire, culinary]

    static let byID: [String: CareerTrack] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

    static func track(forJobID jobID: String) -> CareerTrack? {
        all.first { $0.jobID == jobID }
    }

    static let army = CareerTrack(
        id: "army",
        name: "Army",
        icon: "shield.lefthalf.filled",
        color: .green,
        summary: "Enlist, climb the ranks and maybe make General. Some roles see real combat.",
        minAge: 18, maxJoinAge: 40, minHealth: 45,
        maxRecord: 2, acceptChance: 0.85,
        ranks: [
            CareerRank(title: "Private", salary: 24_000, minYears: 0, minPerformance: 0),
            CareerRank(title: "Private First Class", salary: 27_000, minYears: 1, minPerformance: 40),
            CareerRank(title: "Corporal", salary: 32_000, minYears: 2, minPerformance: 50),
            CareerRank(title: "Sergeant", salary: 38_000, minYears: 2, minPerformance: 55),
            CareerRank(title: "Staff Sergeant", salary: 45_000, minYears: 3, minPerformance: 60),
            CareerRank(title: "Lieutenant", salary: 56_000, minYears: 2, minPerformance: 65, requiresDegree: true),
            CareerRank(title: "Captain", salary: 72_000, minYears: 3, minPerformance: 70, requiresDegree: true),
            CareerRank(title: "Major", salary: 88_000, minYears: 3, minPerformance: 75, requiresDegree: true),
            CareerRank(title: "Colonel", salary: 115_000, minYears: 4, minPerformance: 80, requiresDegree: true, minSmarts: 60),
            CareerRank(title: "General", salary: 190_000, minYears: 5, minPerformance: 88, requiresDegree: true, minSmarts: 70),
        ],
        roles: [
            CareerRole(id: "infantry", title: "Infantry", summary: "Front-line soldier. Dangerous but respected.", payMultiplier: 1.0, risk: 0.55),
            CareerRole(id: "medic", title: "Combat Medic", summary: "Patch up the wounded under fire.", payMultiplier: 1.05, risk: 0.4, minSmarts: 45),
            CareerRole(id: "engineer", title: "Combat Engineer", summary: "Build bridges and clear mines.", payMultiplier: 1.1, risk: 0.4, minSmarts: 50),
            CareerRole(id: "mp", title: "Military Police", summary: "Keep order on base. Rarely sees combat.", payMultiplier: 1.0, risk: 0.15),
            CareerRole(id: "intelligence", title: "Intelligence", summary: "Analyze enemy plans from a safe room.", payMultiplier: 1.2, risk: 0.1, minRank: 2, minSmarts: 65),
            CareerRole(id: "pilot", title: "Helicopter Pilot", summary: "Fly into hot zones. Officers only.", payMultiplier: 1.4, risk: 0.5, minRank: 5, minSmarts: 60, requiresDegree: true),
            CareerRole(id: "special_forces", title: "Special Forces", summary: "Elite missions nobody hears about. Very dangerous.", payMultiplier: 1.5, risk: 0.85, minRank: 3, minHealth: 75),
        ],
        entryRoleIDs: ["infantry", "medic", "engineer", "mp"],
        goodEvents: [
            CareerYearEvent(text: "aced a brutal field exercise", performance: 10, happiness: 4),
            CareerYearEvent(text: "was praised by their commanding officer", performance: 8, happiness: 5),
            CareerYearEvent(text: "trained a group of new recruits", performance: 6, happiness: 3),
        ],
        badEvents: [
            CareerYearEvent(text: "got written up for showing up late to formation", performance: -10, happiness: -4),
            CareerYearEvent(text: "failed a fitness test", performance: -8, happiness: -5),
        ],
        dangerText: "was deployed to a combat zone",
        deathCause: "killed in action while serving in the army"
    )

    static let police = CareerTrack(
        id: "police",
        name: "Police",
        icon: "light.beacon.max.fill",
        color: .blue,
        summary: "Start as a cadet and work up to Chief of Police. Needs a spotless record.",
        minAge: 18, maxJoinAge: 45, minSmarts: 40, minHealth: 40,
        maxRecord: 0, acceptChance: 0.75,
        ranks: [
            CareerRank(title: "Police Cadet", salary: 32_000, minYears: 0, minPerformance: 0),
            CareerRank(title: "Police Officer", salary: 48_000, minYears: 1, minPerformance: 40),
            CareerRank(title: "Senior Officer", salary: 58_000, minYears: 3, minPerformance: 55),
            CareerRank(title: "Sergeant", salary: 70_000, minYears: 3, minPerformance: 62),
            CareerRank(title: "Lieutenant", salary: 85_000, minYears: 3, minPerformance: 70, minSmarts: 55),
            CareerRank(title: "Captain", salary: 105_000, minYears: 4, minPerformance: 76, requiresDegree: true),
            CareerRank(title: "Deputy Chief", salary: 135_000, minYears: 4, minPerformance: 82, requiresDegree: true, minSmarts: 60),
            CareerRank(title: "Chief of Police", salary: 180_000, minYears: 5, minPerformance: 88, requiresDegree: true, minSmarts: 65),
        ],
        roles: [
            CareerRole(id: "patrol", title: "Patrol", summary: "Answer calls and walk the beat.", payMultiplier: 1.0, risk: 0.3),
            CareerRole(id: "traffic", title: "Traffic Unit", summary: "Speed traps and crash scenes. Fairly safe.", payMultiplier: 1.0, risk: 0.15),
            CareerRole(id: "k9", title: "K9 Unit", summary: "Work alongside a police dog.", payMultiplier: 1.1, risk: 0.3, minRank: 1),
            CareerRole(id: "detective", title: "Detective", summary: "Plain clothes and big cases.", payMultiplier: 1.25, risk: 0.25, minRank: 2, minSmarts: 60),
            CareerRole(id: "swat", title: "SWAT", summary: "Raids and hostage situations. High risk.", payMultiplier: 1.35, risk: 0.65, minRank: 1, minHealth: 70),
            CareerRole(id: "undercover", title: "Undercover", summary: "Infiltrate gangs from the inside.", payMultiplier: 1.4, risk: 0.7, minRank: 2, minSmarts: 55),
        ],
        entryRoleIDs: ["patrol", "traffic"],
        goodEvents: [
            CareerYearEvent(text: "made a big arrest that hit the local news", performance: 12, happiness: 6),
            CareerYearEvent(text: "solved a case that had everyone stumped", performance: 10, happiness: 5),
            CareerYearEvent(text: "turned down a bribe from a local dealer", performance: 6, happiness: 2),
        ],
        badEvents: [
            CareerYearEvent(text: "got a complaint filed against them by a citizen", performance: -10, happiness: -5),
            CareerYearEvent(text: "botched the paperwork on an arrest and the suspect walked", performance: -12, happiness: -6),
        ],
        dangerText: "got into a shootout on a call",
        deathCause: "shot in the line of duty as a police officer"
    )

    static let medicine = CareerTrack(
        id: "medicine",
        name: "Medicine",
        icon: "cross.case.fill",
        color: .red,
        summary: "Long hours and huge pay. Needs a degree and serious smarts.",
        minAge: 22, maxJoinAge: 50, requiresDegree: true, minSmarts: 70,
        maxRecord: 0, acceptChance: 0.6,
        ranks: [
            CareerRank(title: "Medical Intern", salary: 55_000, minYears: 0, minPerformance: 0),
            CareerRank(title: "Resident", salary: 68_000, minYears: 1, minPerformance: 45),
            CareerRank(title: "Attending Physician", salary: 210_000, minYears: 3, minPerformance: 60),
            CareerRank(title: "Senior Consultant", salary: 290_000, minYears: 4, minPerformance: 72),
            CareerRank(title: "Chief of Medicine", salary: 420_000, minYears: 5, minPerformance: 85, minSmarts: 80),
        ],
        roles: [
            CareerRole(id: "gp", title: "General Practice", summary: "See a bit of everything.", payMultiplier: 1.0, risk: 0.02),
            CareerRole(id: "pediatrics", title: "Pediatrics", summary: "Look after kids.", payMultiplier: 1.0, risk: 0.02),
            CareerRole(id: "emergency", title: "Emergency Medicine", summary: "Chaos every shift.", payMultiplier: 1.15, risk: 0.05, minRank: 1),
            CareerRole(id: "surgeon", title: "Surgeon", summary: "The most pay, the most pressure.", payMultiplier: 1.5, risk: 0.02, minRank: 1, minSmarts: 80),
        ],
        entryRoleIDs: ["gp", "pediatrics"],
        goodEvents: [
            CareerYearEvent(text: "saved a patient everyone else had given up on", performance: 12, happiness: 7),
            CareerYearEvent(text: "published a paper in a medical journal", performance: 8, happiness: 4),
        ],
        badEvents: [
            CareerYearEvent(text: "made a mistake on a patient's chart and got a warning", performance: -12, happiness: -6),
            CareerYearEvent(text: "burned out after a string of 30-hour shifts", performance: -6, happiness: -8),
        ],
        dangerText: "caught something nasty from a patient",
        deathCause: "an infection caught while treating patients"
    )

    static let law = CareerTrack(
        id: "law",
        name: "Law",
        icon: "building.columns.fill",
        color: .purple,
        summary: "Work your way up to Managing Partner. Lawyers also do better defending themselves in court.",
        minAge: 22, maxJoinAge: 55, requiresDegree: true, minSmarts: 65,
        maxRecord: 0, acceptChance: 0.6,
        ranks: [
            CareerRank(title: "Legal Intern", salary: 40_000, minYears: 0, minPerformance: 0),
            CareerRank(title: "Junior Associate", salary: 85_000, minYears: 1, minPerformance: 45),
            CareerRank(title: "Associate", salary: 120_000, minYears: 2, minPerformance: 55),
            CareerRank(title: "Senior Associate", salary: 165_000, minYears: 3, minPerformance: 65),
            CareerRank(title: "Partner", salary: 320_000, minYears: 4, minPerformance: 78),
            CareerRank(title: "Managing Partner", salary: 600_000, minYears: 5, minPerformance: 88, minSmarts: 80),
        ],
        roles: [
            CareerRole(id: "defense", title: "Criminal Defense", summary: "Get guilty people off. Pays well.", payMultiplier: 1.0, risk: 0.02),
            CareerRole(id: "prosecutor", title: "Prosecutor", summary: "Put criminals away. Pays a little less.", payMultiplier: 0.85, risk: 0.04),
            CareerRole(id: "corporate", title: "Corporate Law", summary: "Mergers and contracts. The big money.", payMultiplier: 1.4, risk: 0.0, minRank: 2),
            CareerRole(id: "family", title: "Family Law", summary: "Divorces and custody battles.", payMultiplier: 0.9, risk: 0.01),
        ],
        entryRoleIDs: ["defense", "prosecutor", "family"],
        goodEvents: [
            CareerYearEvent(text: "won a case nobody thought could be won", performance: 12, happiness: 6),
            CareerYearEvent(text: "brought a big new client to the firm", performance: 10, happiness: 4),
        ],
        badEvents: [
            CareerYearEvent(text: "lost a high-profile case", performance: -10, happiness: -6),
            CareerYearEvent(text: "missed a filing deadline", performance: -12, happiness: -4),
        ],
        dangerText: "got threatened by a client's enemies",
        deathCause: "a revenge attack by someone they put away"
    )

    static let fire = CareerTrack(
        id: "fire",
        name: "Fire Service",
        icon: "flame.fill",
        color: .orange,
        summary: "Run into burning buildings. Tough, risky and respected.",
        minAge: 18, maxJoinAge: 40, minHealth: 55,
        maxRecord: 1, acceptChance: 0.75,
        ranks: [
            CareerRank(title: "Probationary Firefighter", salary: 36_000, minYears: 0, minPerformance: 0),
            CareerRank(title: "Firefighter", salary: 50_000, minYears: 1, minPerformance: 40),
            CareerRank(title: "Driver Engineer", salary: 60_000, minYears: 3, minPerformance: 55),
            CareerRank(title: "Lieutenant", salary: 72_000, minYears: 3, minPerformance: 65),
            CareerRank(title: "Captain", salary: 88_000, minYears: 4, minPerformance: 72),
            CareerRank(title: "Battalion Chief", salary: 115_000, minYears: 4, minPerformance: 80, minSmarts: 55),
            CareerRank(title: "Fire Chief", salary: 160_000, minYears: 5, minPerformance: 88, requiresDegree: true),
        ],
        roles: [
            CareerRole(id: "engine", title: "Engine Company", summary: "Put out the fires.", payMultiplier: 1.0, risk: 0.4),
            CareerRole(id: "paramedic", title: "Paramedic", summary: "First on scene at every emergency.", payMultiplier: 1.05, risk: 0.2, minSmarts: 45),
            CareerRole(id: "rescue", title: "Rescue Squad", summary: "Cut people out of wrecks and collapsed buildings.", payMultiplier: 1.15, risk: 0.5, minRank: 1, minHealth: 65),
            CareerRole(id: "wildland", title: "Wildland Crew", summary: "Fight forest fires for weeks at a time.", payMultiplier: 1.2, risk: 0.6, minRank: 1, minHealth: 70),
            CareerRole(id: "investigator", title: "Fire Investigator", summary: "Figure out who started it.", payMultiplier: 1.15, risk: 0.1, minRank: 2, minSmarts: 60),
        ],
        entryRoleIDs: ["engine", "paramedic"],
        goodEvents: [
            CareerYearEvent(text: "carried a family out of a burning house", performance: 12, happiness: 8),
            CareerYearEvent(text: "won the department's bravery award", performance: 10, happiness: 6),
        ],
        badEvents: [
            CareerYearEvent(text: "froze up at a big fire and got chewed out", performance: -10, happiness: -6),
            CareerYearEvent(text: "crashed the fire truck into a parked car", performance: -12, happiness: -4),
        ],
        dangerText: "got caught in a collapsing building",
        deathCause: "a building collapse while fighting a fire"
    )

    static let culinary = CareerTrack(
        id: "culinary",
        name: "Culinary",
        icon: "fork.knife",
        color: .brown,
        summary: "No degree needed. Start on the line and maybe end up a celebrity chef.",
        minAge: 18, maxJoinAge: 60,
        maxRecord: nil, acceptChance: 0.9,
        ranks: [
            CareerRank(title: "Dishwasher", salary: 22_000, minYears: 0, minPerformance: 0),
            CareerRank(title: "Line Cook", salary: 32_000, minYears: 1, minPerformance: 40),
            CareerRank(title: "Sous Chef", salary: 52_000, minYears: 3, minPerformance: 60),
            CareerRank(title: "Head Chef", salary: 78_000, minYears: 3, minPerformance: 70),
            CareerRank(title: "Executive Chef", salary: 120_000, minYears: 4, minPerformance: 80),
            CareerRank(title: "Celebrity Chef", salary: 450_000, minYears: 5, minPerformance: 92),
        ],
        roles: [
            CareerRole(id: "restaurant", title: "Restaurant Kitchen", summary: "Classic dinner service.", payMultiplier: 1.0, risk: 0.05),
            CareerRole(id: "pastry", title: "Pastry", summary: "Cakes, bread and early mornings.", payMultiplier: 1.0, risk: 0.02),
            CareerRole(id: "catering", title: "Catering", summary: "Weddings and big events.", payMultiplier: 1.1, risk: 0.03, minRank: 1),
            CareerRole(id: "fine_dining", title: "Fine Dining", summary: "Michelin-star pressure.", payMultiplier: 1.35, risk: 0.05, minRank: 2, minSmarts: 50),
        ],
        entryRoleIDs: ["restaurant", "pastry"],
        goodEvents: [
            CareerYearEvent(text: "got a glowing review from a famous food critic", performance: 12, happiness: 7),
            CareerYearEvent(text: "invented a dish that became the restaurant's bestseller", performance: 10, happiness: 5),
        ],
        badEvents: [
            CareerYearEvent(text: "sent out a burnt dish to a VIP table", performance: -10, happiness: -5),
            CareerYearEvent(text: "got screamed at by the head chef all year", performance: -6, happiness: -8),
        ],
        dangerText: "had a nasty accident in the kitchen",
        deathCause: "a kitchen fire"
    )
}
