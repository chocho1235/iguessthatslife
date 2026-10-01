import Foundation

enum NameData {
    private static let maleFirstNames: [CultureRegion: [String]] = [
        .angloWestern: ["James", "Liam", "Noah", "Oliver", "Elijah", "Lucas", "Mason", "Ethan", "Alexander", "Henry", "Daniel", "Matthew", "Jackson", "Benjamin", "Logan", "Jack", "Ryan", "Owen", "Nathan", "Connor"],
        .latinEurope: ["Matteo", "Lorenzo", "Luca", "Gabriel", "Rafael", "Diego", "Mateo", "Santiago", "Joao", "Pablo", "Antoine", "Julien", "Nikolaos", "Dimitris", "Andreas", "Enzo", "Leonardo", "Rodrigo", "Tiago", "Bruno"],
        .germanicNordic: ["Sven", "Lars", "Erik", "Anders", "Magnus", "Felix", "Johan", "Niklas", "Henrik", "Oskar", "Finn", "Axel", "Jonas", "Elias", "Mathias", "Sebastian", "Gustav", "Hans", "Dieter", "Nils"],
        .slavicEastEurope: ["Dmitri", "Ivan", "Pavel", "Mikhail", "Sergei", "Viktor", "Jakub", "Tomasz", "Stefan", "Milan", "Andrei", "Alexei", "Oleg", "Piotr", "Radu", "Marek", "Vasyl", "Bogdan", "Zoltan", "Luka"],
        .eastAsia: ["Wei", "Hiroshi", "Kenji", "Jin", "Haruto", "Min-jun", "Tao", "Jun", "Ren", "Daiki", "Sora", "Yong", "Liang", "Kai", "Hao", "Satoshi", "Seo-jun", "Chen", "Takumi", "Yuto"],
        .southAsia: ["Arjun", "Rohan", "Vikram", "Aditya", "Rahul", "Karan", "Dev", "Ishaan", "Aarav", "Sameer", "Imran", "Faisal", "Nabil", "Tariq", "Kabir", "Sanjay", "Anand", "Raj", "Nikhil", "Omar"],
        .southeastAsia: ["Budi", "Agus", "Made", "Wayan", "Nguyen", "Minh", "Duc", "Somchai", "Niran", "Arief", "Rizky", "Jose", "Ramon", "Danilo", "Hung", "Tuan", "Aung", "Zaw", "Chea", "Pich"],
        .middleEastNorthAfrica: ["Youssef", "Ahmed", "Mohammed", "Karim", "Omar", "Hassan", "Khalid", "Tariq", "Amir", "Samir", "Rami", "Faisal", "Ziad", "Nasser", "Mahmoud", "Adel", "Reza", "Dariush", "Kian", "Farid"],
        .subSaharanAfrica: ["Kwame", "Kofi", "Chidi", "Emeka", "Tendai", "Sipho", "Thabo", "Amadou", "Moussa", "Ibrahim", "Kwabena", "Olusegun", "Chikwendu", "Mandla", "Lesedi", "Jabari", "Kagiso", "Yaw", "Femi", "Abebe"],
        .latinAmerica: ["Diego", "Mateo", "Santiago", "Alejandro", "Gabriel", "Rodrigo", "Emiliano", "Joaquin", "Nicolas", "Sebastian", "Lucas", "Pedro", "Thiago", "Rafael", "Bruno", "Andres", "Felipe", "Martin", "Agustin", "Ricardo"],
    ]

    private static let femaleFirstNames: [CultureRegion: [String]] = [
        .angloWestern: ["Olivia", "Emma", "Ava", "Sophia", "Isabella", "Mia", "Charlotte", "Amelia", "Harper", "Evelyn", "Abigail", "Ella", "Scarlett", "Grace", "Chloe", "Victoria", "Riley", "Aria", "Lily", "Zoey"],
        .latinEurope: ["Giulia", "Chiara", "Sofia", "Valentina", "Camila", "Ines", "Manon", "Chloe", "Eleni", "Maria", "Carla", "Beatriz", "Francesca", "Alessia", "Lucia", "Marianna", "Anastasia", "Carmen", "Daniela", "Teresa"],
        .germanicNordic: ["Freya", "Ingrid", "Astrid", "Greta", "Hanna", "Elin", "Sigrid", "Johanna", "Karin", "Lotta", "Else", "Birgit", "Mathilde", "Kirsten", "Annika", "Lena", "Petra", "Ulrike", "Solveig", "Liv"],
        .slavicEastEurope: ["Katarina", "Natasha", "Olga", "Irina", "Anya", "Daria", "Marta", "Zofia", "Elena", "Milena", "Ksenia", "Yelena", "Anastasia", "Viktoria", "Jovana", "Dorota", "Ivana", "Nadia", "Tatiana", "Larisa"],
        .eastAsia: ["Mei", "Sakura", "Yuki", "Hana", "Ji-woo", "Lin", "Xia", "Akari", "Seo-yeon", "Yumi", "Ling", "Momoka", "Eun-ji", "Rin", "Fang", "Aiko", "Hyun-woo", "Yue", "Nana", "Mi-rae"],
        .southAsia: ["Priya", "Ananya", "Divya", "Neha", "Pooja", "Sana", "Zara", "Fatima", "Amara", "Isha", "Meera", "Kavya", "Aisha", "Layla", "Nisha", "Ritu", "Shreya", "Noor", "Simran", "Anika"],
        .southeastAsia: ["Siti", "Putri", "Dewi", "Linh", "Thuy", "Mai", "Malee", "Suda", "Nok", "Bella", "Rosa", "Jasmine", "Trang", "Hoa", "Aye", "Thida", "Sopheap", "Channary", "Grace", "Ivy"],
        .middleEastNorthAfrica: ["Fatima", "Layla", "Amira", "Yasmin", "Noor", "Zainab", "Mariam", "Rania", "Dalia", "Salma", "Leila", "Samira", "Hadiya", "Nour", "Hala", "Shirin", "Donya", "Parisa", "Negar", "Roya"],
        .subSaharanAfrica: ["Amara", "Chiamaka", "Ngozi", "Thandiwe", "Zola", "Fatou", "Aminata", "Nia", "Folasade", "Adaeze", "Kagiso", "Lesedi", "Zuri", "Oluwaseun", "Chidinma", "Makena", "Asha", "Imani", "Abeni", "Wanjiru"],
        .latinAmerica: ["Valentina", "Camila", "Sofia", "Isabella", "Mariana", "Gabriela", "Daniela", "Fernanda", "Lucia", "Victoria", "Ximena", "Renata", "Paula", "Carolina", "Antonella", "Julieta", "Rocio", "Alejandra", "Catalina", "Bianca"],
    ]

    private static let lastNames: [CultureRegion: [String]] = [
        .angloWestern: ["Smith", "Johnson", "Williams", "Brown", "Jones", "Wilson", "Anderson", "Taylor", "Moore", "Jackson", "Martin", "Clark", "Lewis", "Walker", "Young", "King", "Wright", "Scott", "Green", "Baker"],
        .latinEurope: ["Rossi", "Ferrari", "Esposito", "Martinez", "Garcia", "Lopez", "Dubois", "Lefevre", "Moreau", "Silva", "Costa", "Ferreira", "Papadopoulos", "Nikolaou", "Ruiz", "Fernandez", "Gomez", "Romano", "Bianchi", "Conti"],
        .germanicNordic: ["Müller", "Schmidt", "Fischer", "Weber", "Andersson", "Johansson", "Eriksson", "Nilsson", "Van Berg", "De Vries", "Hansen", "Nielsen", "Berg", "Larsen", "Lindqvist", "Keller", "Hoffmann", "Wagner", "Brandt", "Olsen"],
        .slavicEastEurope: ["Kowalski", "Nowak", "Wojcik", "Novak", "Dvorak", "Horvat", "Petrov", "Ivanov", "Sokolov", "Volkov", "Kovac", "Jankovic", "Popescu", "Ionescu", "Kravchenko", "Bondar", "Melnyk", "Krasniqi", "Simic", "Vidic"],
        .eastAsia: ["Nakamura", "Tanaka", "Suzuki", "Kim", "Park", "Lee", "Wang", "Li", "Zhang", "Chen", "Watanabe", "Sato", "Takahashi", "Choi", "Yamamoto", "Liu", "Huang", "Jung", "Kobayashi", "Han"],
        .southAsia: ["Sharma", "Patel", "Khan", "Singh", "Gupta", "Verma", "Hussain", "Ahmed", "Reddy", "Iyer", "Chaudhary", "Malik", "Shah", "Rahman", "Bose", "Nair", "Kapoor", "Mehta", "Desai", "Qureshi"],
        .southeastAsia: ["Santos", "Cruz", "Reyes", "Nguyen", "Tran", "Pham", "Suwanaphan", "Wattana", "Hidayat", "Wijaya", "Lim", "Tan", "Bautista", "Garcia", "Phan", "Le", "Rakoto", "Chea", "Soe", "Aung"],
        .middleEastNorthAfrica: ["Hassan", "Ibrahim", "Mahmoud", "Farouk", "Khalil", "Saleh", "Haddad", "Mansour", "Aziz", "Karimi", "Rahimi", "Nasser", "Rostami", "Hosseini", "Tahir", "Abdullah", "Yilmaz", "Demir", "Kaya", "Celik"],
        .subSaharanAfrica: ["Okafor", "Adeyemi", "Mensah", "Dlamini", "Mwangi", "Diallo", "Toure", "Osei", "Abara", "Nwosu", "Mutombo", "Kamau", "Banda", "Chukwu", "Okoro", "Abiola", "Keita", "Sow", "Mbeki", "Gueye"],
        .latinAmerica: ["Garcia", "Rodriguez", "Martinez", "Hernandez", "Gonzalez", "Perez", "Sanchez", "Ramirez", "Torres", "Flores", "Silva", "Oliveira", "Santos", "Castro", "Rojas", "Vargas", "Diaz", "Morales", "Gutierrez", "Mendoza"],
    ]

    static func randomFirstName(for gender: Gender, region: CultureRegion = .angloWestern) -> String {
        let pool = (gender == .male ? maleFirstNames : femaleFirstNames)[region] ?? maleFirstNames[.angloWestern]!
        return pool.randomElement()!
    }

    static func randomLastName(region: CultureRegion = .angloWestern) -> String {
        (lastNames[region] ?? lastNames[.angloWestern]!).randomElement()!
    }

    static func randomCountry() -> String {
        CountryData.allCountryNames().randomElement()!
    }
}
