import Foundation

enum JobData {
    static let all: [Job] = [
        // Part-time (teens)
        Job(id: "mcfries", title: "McFries Crew Member", category: "Food Service", baseSalary: 2200, requiresDegree: false, isPartTime: true),
        Job(id: "wallys_clerk", title: "Wally's Mart Stock Clerk", category: "Retail", baseSalary: 2500, requiresDegree: false, isPartTime: true),
        Job(id: "starbeans", title: "Star Beans Barista", category: "Food Service", baseSalary: 2300, requiresDegree: false, isPartTime: true),
        Job(id: "dogwalker", title: "PawsitiveCare Dog Walker", category: "Pet Care", baseSalary: 1800, requiresDegree: false, isPartTime: true),
        Job(id: "usher", title: "PixelPlex Cinemas Usher", category: "Entertainment", baseSalary: 2100, requiresDegree: false, isPartTime: true),
        Job(id: "market_helper", title: "Local Market Helper", category: "Trade", baseSalary: 4000, requiresDegree: false, isPartTime: true, maxSalaryMultiplier: 0.4),

        // Full-time, no degree required
        Job(id: "wallys_supervisor", title: "Wally's Mart Shift Supervisor", category: "Retail", baseSalary: 28000, requiresDegree: false, isPartTime: false),
        Job(id: "amazonia", title: "Amazonia Warehouse Associate", category: "Logistics", baseSalary: 32000, requiresDegree: false, isPartTime: false, minSalaryMultiplier: 0.3),
        Job(id: "construction", title: "BuildRight Construction Worker", category: "Trades", baseSalary: 34000, requiresDegree: false, isPartTime: false),
        Job(id: "speedex", title: "SpeedEx Delivery Driver", category: "Logistics", baseSalary: 30000, requiresDegree: false, isPartTime: false, minSalaryMultiplier: 0.25),
        Job(id: "security", title: "SecureNet Security Guard", category: "Security", baseSalary: 29000, requiresDegree: false, isPartTime: false),

        // Full-time, degree required
        Job(id: "goggle_swe", title: "Goggle Software Engineer", category: "Tech", baseSalary: 95000, requiresDegree: true, isPartTime: false, minSalaryMultiplier: 0.5),
        Job(id: "paralegal", title: "Lex & Partners Paralegal", category: "Law", baseSalary: 52000, requiresDegree: true, isPartTime: false, minSalaryMultiplier: 0.3),
        Job(id: "nurse", title: "Sunrise General Hospital Nurse", category: "Medicine", baseSalary: 68000, requiresDegree: true, isPartTime: false),
        Job(id: "analyst", title: "Meridian Bank Financial Analyst", category: "Finance", baseSalary: 72000, requiresDegree: true, isPartTime: false, minSalaryMultiplier: 0.45),
        Job(id: "teacher", title: "Crestwood Academy Teacher", category: "Education", baseSalary: 48000, requiresDegree: true, isPartTime: false),
        Job(id: "architect", title: "Skyline Architecture Designer", category: "Architecture", baseSalary: 65000, requiresDegree: true, isPartTime: false, minSalaryMultiplier: 0.35),
        Job(id: "designer", title: "Nova Media Graphic Designer", category: "Creative", baseSalary: 50000, requiresDegree: true, isPartTime: false, minSalaryMultiplier: 0.3),
        Job(id: "consultant", title: "Apex Consulting Strategist", category: "Business", baseSalary: 85000, requiresDegree: true, isPartTime: false, minSalaryMultiplier: 0.55),

        // Jobs tied to developing economies — pay less in absolute terms, but
        // disappear entirely once a country's wages climb past this tier.
        Job(id: "farmhand", title: "Farmhand", category: "Agriculture", baseSalary: 18000, requiresDegree: false, isPartTime: false, maxSalaryMultiplier: 0.35),
        Job(id: "textile_worker", title: "Textile Mill Worker", category: "Manufacturing", baseSalary: 16000, requiresDegree: false, isPartTime: false, maxSalaryMultiplier: 0.3),
        Job(id: "street_vendor", title: "Street Food Vendor", category: "Trade", baseSalary: 15000, requiresDegree: false, isPartTime: false, maxSalaryMultiplier: 0.35),
        Job(id: "tour_guide", title: "Local Tour Guide", category: "Tourism", baseSalary: 20000, requiresDegree: false, isPartTime: false, maxSalaryMultiplier: 0.5),

        // High-tier finance/luxury roles that only exist in the richest economies.
        Job(id: "private_banker", title: "Private Wealth Banker", category: "Finance", baseSalary: 140000, requiresDegree: true, isPartTime: false, minSalaryMultiplier: 0.9),
        Job(id: "yacht_broker", title: "Luxury Yacht Broker", category: "Sales", baseSalary: 110000, requiresDegree: false, isPartTime: false, minSalaryMultiplier: 0.95),
    ]

    static let byID: [String: Job] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

    static func available(stage: LifeStage, educationLevel: EducationLevel, country: String) -> [Job] {
        let multiplier = CountryData.profile(for: country).salaryMultiplier
        let localJobs = all.filter { multiplier >= $0.minSalaryMultiplier && multiplier <= $0.maxSalaryMultiplier }
        switch stage {
        case .teen:
            return localJobs.filter(\.isPartTime)
        case .adult, .senior:
            return localJobs.filter { !$0.isPartTime && (!$0.requiresDegree || educationLevel == .university) }
        case .infant, .child:
            return []
        }
    }
}
