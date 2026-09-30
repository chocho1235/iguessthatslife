import Foundation

struct CountryProfile {
    let universities: [String]
    let salaryMultiplier: Double
}

enum CountryData {
    static let profiles: [String: CountryProfile] = [
        "United States": CountryProfile(universities: ["Ivy Grove University", "Pacific Crest University"], salaryMultiplier: 1.0),
        "United Kingdom": CountryProfile(universities: ["Camrose University", "Kingsmere College"], salaryMultiplier: 0.9),
        "Canada": CountryProfile(universities: ["Maple Ridge University", "Northern Lights University"], salaryMultiplier: 0.88),
        "Australia": CountryProfile(universities: ["Sydney Coastal University", "Outback State University"], salaryMultiplier: 0.95),
        "Germany": CountryProfile(universities: ["Bergstadt Technical University", "Rheinfeld University"], salaryMultiplier: 0.85),
        "France": CountryProfile(universities: ["Université de Montclair", "Lumière Institute"], salaryMultiplier: 0.8),
        "Brazil": CountryProfile(universities: ["Universidade Costa Verde", "Instituto Rio Novo"], salaryMultiplier: 0.35),
        "Japan": CountryProfile(universities: ["Tokyo Institute of Advanced Studies", "Sakura University"], salaryMultiplier: 0.92),
        "South Africa": CountryProfile(universities: ["Cape Ridge University", "Savanna State University"], salaryMultiplier: 0.3),
        "Mexico": CountryProfile(universities: ["Universidad del Sol", "Instituto Azteca"], salaryMultiplier: 0.28),
        "Italy": CountryProfile(universities: ["Università di Bellavista", "Accademia Roma Nord"], salaryMultiplier: 0.75),
        "Spain": CountryProfile(universities: ["Universidad del Mar", "Instituto Iberia"], salaryMultiplier: 0.7),
        "India": CountryProfile(universities: ["Indraprastha University", "Ganges Valley Institute"], salaryMultiplier: 0.25),
        "China": CountryProfile(universities: ["Great Wall University", "Yangtze Institute of Technology"], salaryMultiplier: 0.5),
        "South Korea": CountryProfile(universities: ["Hangang University", "Baekdu Institute"], salaryMultiplier: 0.85),
        "Netherlands": CountryProfile(universities: ["Delta Polytechnic University", "Windmill City College"], salaryMultiplier: 0.9),
        "Sweden": CountryProfile(universities: ["Nordic Lights University", "Fjord Institute"], salaryMultiplier: 0.95),
        "Ireland": CountryProfile(universities: ["Emerald Isle University", "Shamrock College"], salaryMultiplier: 0.85),
        "Argentina": CountryProfile(universities: ["Universidad de la Pampa", "Instituto Patagonia"], salaryMultiplier: 0.3),
        "Egypt": CountryProfile(universities: ["Nile Valley University", "Pyramid Institute of Technology"], salaryMultiplier: 0.2),
        "Nigeria": CountryProfile(universities: ["Lagos Coast University", "Savannah Institute"], salaryMultiplier: 0.15),
        "Poland": CountryProfile(universities: ["Vistula University", "Amber Coast Institute"], salaryMultiplier: 0.55),
        "Switzerland": CountryProfile(universities: ["Alpine Federal University", "Matterhorn Institute"], salaryMultiplier: 1.1),
        "New Zealand": CountryProfile(universities: ["Kiwi Coast University", "Southern Alps College"], salaryMultiplier: 0.9),
    ]

    static func profile(for country: String) -> CountryProfile {
        profiles[country] ?? CountryProfile(universities: ["State University", "City College"], salaryMultiplier: 0.8)
    }
}
