import Foundation

enum NameData {
    static let maleFirstNames = [
        "James", "Liam", "Noah", "Oliver", "Elijah", "Lucas", "Mason", "Ethan",
        "Alexander", "Henry", "Daniel", "Matthew", "Jackson", "Sebastian", "Owen",
        "Samuel", "Joseph", "David", "Carter", "Wyatt",
        "Benjamin", "Logan", "Michael", "Ezra", "Jack", "Levi", "Julian", "Isaac",
        "Gabriel", "Anthony", "Dylan", "Leo", "Lincoln", "Christopher", "Nathan",
        "Ryan", "Adrian", "Robert", "Angel", "Kai",
        "Arjun", "Wei", "Hiroshi", "Sven", "Finn", "Diego", "Mateo", "Kwame",
        "Youssef", "Dmitri",
    ]

    static let femaleFirstNames = [
        "Olivia", "Emma", "Ava", "Sophia", "Isabella", "Mia", "Charlotte", "Amelia",
        "Harper", "Evelyn", "Abigail", "Ella", "Scarlett", "Grace", "Chloe",
        "Victoria", "Riley", "Aria", "Lily", "Zoey",
        "Nora", "Hazel", "Zoe", "Layla", "Ellie", "Stella", "Natalie", "Leah",
        "Aurora", "Savannah", "Audrey", "Brooklyn", "Bella", "Claire", "Skylar",
        "Lucy", "Paisley", "Everly", "Anna", "Caroline",
        "Priya", "Mei", "Sakura", "Freya", "Camila", "Valentina", "Amara",
        "Fatima", "Ingrid", "Katarina",
    ]

    static let lastNames = [
        "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller",
        "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez",
        "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin",
        "Clark", "Lewis", "Walker", "Young", "King", "Wright", "Scott", "Green",
        "Baker", "Nelson", "Carter", "Mitchell", "Roberts", "Turner", "Phillips",
        "Campbell", "Parker", "Evans", "Edwards", "Collins",
        "Müller", "Rossi", "Nakamura", "Kowalski", "Andersson", "Dubois",
        "O'Brien", "Silva", "Kim", "Nguyen",
    ]

    static let countries = [
        "United States", "United Kingdom", "Canada", "Australia", "Germany",
        "France", "Brazil", "Japan", "South Africa", "Mexico", "Italy", "Spain",
        "India", "China", "South Korea", "Netherlands", "Sweden", "Ireland",
        "Argentina", "Egypt", "Nigeria", "Poland", "Switzerland", "New Zealand",
    ]

    static func randomFirstName(for gender: Gender) -> String {
        (gender == .male ? maleFirstNames : femaleFirstNames).randomElement()!
    }

    static func randomLastName() -> String {
        lastNames.randomElement()!
    }

    static func randomCountry() -> String {
        countries.randomElement()!
    }
}
