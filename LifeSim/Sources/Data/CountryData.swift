import Foundation

struct CountryProfile {
    let universities: [String]
    let salaryMultiplier: Double
    let capital: String
    let language: String
    let currency: String
    let landmark: String
    let latitude: Double
    let longitude: Double
    let region: CultureRegion
}

enum CountryData {
    static let profiles: [String: CountryProfile] = [
        // Anglo / Western
        "United States": CountryProfile(universities: ["Ivy Grove University", "Pacific Crest University"], salaryMultiplier: 1.0, capital: "Washington, D.C.", language: "English", currency: "US Dollar", landmark: "Statue of Liberty", latitude: 38.9, longitude: -77.0, region: .angloWestern),
        "United Kingdom": CountryProfile(universities: ["Camrose University", "Kingsmere College"], salaryMultiplier: 0.9, capital: "London", language: "English", currency: "Pound Sterling", landmark: "Big Ben", latitude: 51.5, longitude: -0.1, region: .angloWestern),
        "Canada": CountryProfile(universities: ["Maple Ridge University", "Northern Lights University"], salaryMultiplier: 0.88, capital: "Ottawa", language: "English", currency: "Canadian Dollar", landmark: "Niagara Falls", latitude: 45.4, longitude: -75.7, region: .angloWestern),
        "Australia": CountryProfile(universities: ["Sydney Coastal University", "Outback State University"], salaryMultiplier: 0.95, capital: "Canberra", language: "English", currency: "Australian Dollar", landmark: "Sydney Opera House", latitude: -35.3, longitude: 149.1, region: .angloWestern),
        "Ireland": CountryProfile(universities: ["Emerald Isle University", "Shamrock College"], salaryMultiplier: 0.85, capital: "Dublin", language: "English", currency: "Euro", landmark: "Cliffs of Moher", latitude: 53.35, longitude: -6.26, region: .angloWestern),
        "New Zealand": CountryProfile(universities: ["Kiwi Coast University", "Southern Alps College"], salaryMultiplier: 0.9, capital: "Wellington", language: "English", currency: "New Zealand Dollar", landmark: "Milford Sound", latitude: -41.29, longitude: 174.78, region: .angloWestern),

        // Latin Europe
        "France": CountryProfile(universities: ["Université de Montclair", "Lumière Institute"], salaryMultiplier: 0.8, capital: "Paris", language: "French", currency: "Euro", landmark: "Eiffel Tower", latitude: 48.85, longitude: 2.35, region: .latinEurope),
        "Italy": CountryProfile(universities: ["Università di Bellavista", "Accademia Roma Nord"], salaryMultiplier: 0.75, capital: "Rome", language: "Italian", currency: "Euro", landmark: "Colosseum", latitude: 41.9, longitude: 12.5, region: .latinEurope),
        "Spain": CountryProfile(universities: ["Universidad del Mar", "Instituto Iberia"], salaryMultiplier: 0.7, capital: "Madrid", language: "Spanish", currency: "Euro", landmark: "Sagrada Família", latitude: 40.4, longitude: -3.7, region: .latinEurope),
        "Portugal": CountryProfile(universities: ["Universidade de Alvorada", "Instituto Atlântico"], salaryMultiplier: 0.65, capital: "Lisbon", language: "Portuguese", currency: "Euro", landmark: "Belém Tower", latitude: 38.72, longitude: -9.14, region: .latinEurope),
        "Greece": CountryProfile(universities: ["University of Aegea", "Olympus Institute"], salaryMultiplier: 0.6, capital: "Athens", language: "Greek", currency: "Euro", landmark: "Acropolis", latitude: 37.98, longitude: 23.73, region: .latinEurope),

        // Germanic / Nordic
        "Germany": CountryProfile(universities: ["Bergstadt Technical University", "Rheinfeld University"], salaryMultiplier: 0.85, capital: "Berlin", language: "German", currency: "Euro", landmark: "Brandenburg Gate", latitude: 52.5, longitude: 13.4, region: .germanicNordic),
        "Netherlands": CountryProfile(universities: ["Delta Polytechnic University", "Windmill City College"], salaryMultiplier: 0.9, capital: "Amsterdam", language: "Dutch", currency: "Euro", landmark: "Windmills of Kinderdijk", latitude: 52.37, longitude: 4.9, region: .germanicNordic),
        "Sweden": CountryProfile(universities: ["Nordic Lights University", "Fjord Institute"], salaryMultiplier: 0.95, capital: "Stockholm", language: "Swedish", currency: "Swedish Krona", landmark: "Vasa Museum", latitude: 59.33, longitude: 18.07, region: .germanicNordic),
        "Switzerland": CountryProfile(universities: ["Alpine Federal University", "Matterhorn Institute"], salaryMultiplier: 1.1, capital: "Bern", language: "German", currency: "Swiss Franc", landmark: "The Matterhorn", latitude: 46.95, longitude: 7.45, region: .germanicNordic),
        "Norway": CountryProfile(universities: ["University of Fjordheim", "Northern Lights Institute"], salaryMultiplier: 1.05, capital: "Oslo", language: "Norwegian", currency: "Norwegian Krone", landmark: "Geirangerfjord", latitude: 59.91, longitude: 10.75, region: .germanicNordic),
        "Denmark": CountryProfile(universities: ["University of Copenhagen Sound", "Viking Coast College"], salaryMultiplier: 1.0, capital: "Copenhagen", language: "Danish", currency: "Danish Krone", landmark: "The Little Mermaid statue", latitude: 55.68, longitude: 12.57, region: .germanicNordic),
        "Finland": CountryProfile(universities: ["University of Suomi", "Lakeland Institute of Technology"], salaryMultiplier: 0.92, capital: "Helsinki", language: "Finnish", currency: "Euro", landmark: "Suomenlinna Fortress", latitude: 60.17, longitude: 24.94, region: .germanicNordic),
        "Belgium": CountryProfile(universities: ["University of Flandria", "Waffle City College"], salaryMultiplier: 0.88, capital: "Brussels", language: "Dutch", currency: "Euro", landmark: "Atomium", latitude: 50.85, longitude: 4.35, region: .germanicNordic),
        "Austria": CountryProfile(universities: ["University of Alpenburg", "Imperial Conservatory Institute"], salaryMultiplier: 0.9, capital: "Vienna", language: "German", currency: "Euro", landmark: "Schönbrunn Palace", latitude: 48.21, longitude: 16.37, region: .germanicNordic),
        "Iceland": CountryProfile(universities: ["University of Reykjavík Bay", "Glacier Institute"], salaryMultiplier: 1.0, capital: "Reykjavík", language: "Icelandic", currency: "Icelandic Króna", landmark: "Blue Lagoon", latitude: 64.15, longitude: -21.94, region: .germanicNordic),

        // Slavic / Eastern Europe
        "Poland": CountryProfile(universities: ["Vistula University", "Amber Coast Institute"], salaryMultiplier: 0.55, capital: "Warsaw", language: "Polish", currency: "Polish Złoty", landmark: "Wawel Castle", latitude: 52.23, longitude: 21.01, region: .slavicEastEurope),
        "Czech Republic": CountryProfile(universities: ["University of Bohemia", "Charles Bridge Institute"], salaryMultiplier: 0.6, capital: "Prague", language: "Czech", currency: "Czech Koruna", landmark: "Charles Bridge", latitude: 50.08, longitude: 14.44, region: .slavicEastEurope),
        "Hungary": CountryProfile(universities: ["University of Danubia", "Thermal Spa Institute"], salaryMultiplier: 0.5, capital: "Budapest", language: "Hungarian", currency: "Hungarian Forint", landmark: "Fisherman's Bastion", latitude: 47.5, longitude: 19.04, region: .slavicEastEurope),
        "Romania": CountryProfile(universities: ["University of Carpathia", "Transylvania Institute"], salaryMultiplier: 0.4, capital: "Bucharest", language: "Romanian", currency: "Romanian Leu", landmark: "Bran Castle", latitude: 44.43, longitude: 26.1, region: .slavicEastEurope),
        "Croatia": CountryProfile(universities: ["University of Adria", "Dalmatian Coast College"], salaryMultiplier: 0.45, capital: "Zagreb", language: "Croatian", currency: "Euro", landmark: "Plitvice Lakes", latitude: 45.81, longitude: 15.98, region: .slavicEastEurope),
        "Serbia": CountryProfile(universities: ["University of Belgrade Heights", "Balkan Institute"], salaryMultiplier: 0.35, capital: "Belgrade", language: "Serbian", currency: "Serbian Dinar", landmark: "Belgrade Fortress", latitude: 44.79, longitude: 20.45, region: .slavicEastEurope),
        "Bulgaria": CountryProfile(universities: ["University of Thracia", "Rose Valley Institute"], salaryMultiplier: 0.38, capital: "Sofia", language: "Bulgarian", currency: "Bulgarian Lev", landmark: "Rila Monastery", latitude: 42.7, longitude: 23.32, region: .slavicEastEurope),
        "Slovakia": CountryProfile(universities: ["University of Tatra", "Danube Institute"], salaryMultiplier: 0.5, capital: "Bratislava", language: "Slovak", currency: "Euro", landmark: "Bratislava Castle", latitude: 48.15, longitude: 17.11, region: .slavicEastEurope),
        "Slovenia": CountryProfile(universities: ["University of Julian Alps", "Lake Bled Institute"], salaryMultiplier: 0.58, capital: "Ljubljana", language: "Slovenian", currency: "Euro", landmark: "Lake Bled", latitude: 46.06, longitude: 14.5, region: .slavicEastEurope),
        "Lithuania": CountryProfile(universities: ["University of Baltica", "Amber Institute"], salaryMultiplier: 0.48, capital: "Vilnius", language: "Lithuanian", currency: "Euro", landmark: "Trakai Castle", latitude: 54.69, longitude: 25.28, region: .slavicEastEurope),
        "Latvia": CountryProfile(universities: ["University of Riga Bay", "Baltic Coast Institute"], salaryMultiplier: 0.45, capital: "Riga", language: "Latvian", currency: "Euro", landmark: "House of the Blackheads", latitude: 56.95, longitude: 24.11, region: .slavicEastEurope),
        "Estonia": CountryProfile(universities: ["University of Tallinn Bay", "Digital Nation Institute"], salaryMultiplier: 0.5, capital: "Tallinn", language: "Estonian", currency: "Euro", landmark: "Tallinn Old Town", latitude: 59.44, longitude: 24.75, region: .slavicEastEurope),
        "Ukraine": CountryProfile(universities: ["University of Kyiv Hills", "Dnipro Institute"], salaryMultiplier: 0.2, capital: "Kyiv", language: "Ukrainian", currency: "Ukrainian Hryvnia", landmark: "Saint Sophia Cathedral", latitude: 50.45, longitude: 30.52, region: .slavicEastEurope),
        "Russia": CountryProfile(universities: ["University of Moskva", "Siberian Institute of Technology"], salaryMultiplier: 0.3, capital: "Moscow", language: "Russian", currency: "Russian Ruble", landmark: "Red Square", latitude: 55.76, longitude: 37.62, region: .slavicEastEurope),

        // East Asia
        "Japan": CountryProfile(universities: ["Tokyo Institute of Advanced Studies", "Sakura University"], salaryMultiplier: 0.92, capital: "Tokyo", language: "Japanese", currency: "Japanese Yen", landmark: "Mount Fuji", latitude: 35.68, longitude: 139.69, region: .eastAsia),
        "China": CountryProfile(universities: ["Great Wall University", "Yangtze Institute of Technology"], salaryMultiplier: 0.5, capital: "Beijing", language: "Mandarin", currency: "Renminbi", landmark: "Great Wall of China", latitude: 39.9, longitude: 116.4, region: .eastAsia),
        "South Korea": CountryProfile(universities: ["Hangang University", "Baekdu Institute"], salaryMultiplier: 0.85, capital: "Seoul", language: "Korean", currency: "South Korean Won", landmark: "Gyeongbokgung Palace", latitude: 37.57, longitude: 126.98, region: .eastAsia),
        "Taiwan": CountryProfile(universities: ["University of Formosa", "Taipei Institute of Technology"], salaryMultiplier: 0.8, capital: "Taipei", language: "Mandarin", currency: "New Taiwan Dollar", landmark: "Taipei 101", latitude: 25.03, longitude: 121.56, region: .eastAsia),
        "Mongolia": CountryProfile(universities: ["University of the Steppe", "Gobi Institute"], salaryMultiplier: 0.25, capital: "Ulaanbaatar", language: "Mongolian", currency: "Mongolian Tögrög", landmark: "Gobi Desert", latitude: 47.92, longitude: 106.92, region: .eastAsia),

        // South Asia
        "India": CountryProfile(universities: ["Indraprastha University", "Ganges Valley Institute"], salaryMultiplier: 0.25, capital: "New Delhi", language: "Hindi", currency: "Indian Rupee", landmark: "Taj Mahal", latitude: 28.6, longitude: 77.2, region: .southAsia),
        "Pakistan": CountryProfile(universities: ["University of Indus", "Karakoram Institute"], salaryMultiplier: 0.15, capital: "Islamabad", language: "Urdu", currency: "Pakistani Rupee", landmark: "Badshahi Mosque", latitude: 33.68, longitude: 73.05, region: .southAsia),
        "Bangladesh": CountryProfile(universities: ["University of Padma", "Delta Institute of Technology"], salaryMultiplier: 0.12, capital: "Dhaka", language: "Bengali", currency: "Bangladeshi Taka", landmark: "Sundarbans", latitude: 23.81, longitude: 90.41, region: .southAsia),
        "Sri Lanka": CountryProfile(universities: ["University of Ceylon Hills", "Spice Coast Institute"], salaryMultiplier: 0.2, capital: "Colombo", language: "Sinhala", currency: "Sri Lankan Rupee", landmark: "Sigiriya Rock", latitude: 6.93, longitude: 79.85, region: .southAsia),
        "Nepal": CountryProfile(universities: ["University of Himalaya", "Kathmandu Valley Institute"], salaryMultiplier: 0.12, capital: "Kathmandu", language: "Nepali", currency: "Nepalese Rupee", landmark: "Mount Everest", latitude: 27.72, longitude: 85.32, region: .southAsia),

        // Southeast Asia
        "Indonesia": CountryProfile(universities: ["University of Nusantara", "Java Institute of Technology"], salaryMultiplier: 0.3, capital: "Jakarta", language: "Indonesian", currency: "Indonesian Rupiah", landmark: "Borobudur Temple", latitude: -6.21, longitude: 106.85, region: .southeastAsia),
        "Philippines": CountryProfile(universities: ["University of Luzon Bay", "Pearl Islands Institute"], salaryMultiplier: 0.25, capital: "Manila", language: "Filipino", currency: "Philippine Peso", landmark: "Chocolate Hills", latitude: 14.6, longitude: 120.98, region: .southeastAsia),
        "Vietnam": CountryProfile(universities: ["University of Mekong Delta", "Hanoi Institute of Technology"], salaryMultiplier: 0.25, capital: "Hanoi", language: "Vietnamese", currency: "Vietnamese Dong", landmark: "Ha Long Bay", latitude: 21.03, longitude: 105.85, region: .southeastAsia),
        "Thailand": CountryProfile(universities: ["University of Siam", "Chao Phraya Institute"], salaryMultiplier: 0.35, capital: "Bangkok", language: "Thai", currency: "Thai Baht", landmark: "Grand Palace", latitude: 13.76, longitude: 100.5, region: .southeastAsia),
        "Malaysia": CountryProfile(universities: ["University of Malaya Strait", "Borneo Institute of Technology"], salaryMultiplier: 0.45, capital: "Kuala Lumpur", language: "Malay", currency: "Malaysian Ringgit", landmark: "Petronas Towers", latitude: 3.14, longitude: 101.69, region: .southeastAsia),
        "Singapore": CountryProfile(universities: ["Marina Institute of Technology", "Raffles University"], salaryMultiplier: 1.0, capital: "Singapore", language: "English", currency: "Singapore Dollar", landmark: "Marina Bay Sands", latitude: 1.35, longitude: 103.82, region: .southeastAsia),
        "Myanmar": CountryProfile(universities: ["University of Irrawaddy", "Golden Pagoda Institute"], salaryMultiplier: 0.12, capital: "Naypyidaw", language: "Burmese", currency: "Burmese Kyat", landmark: "Shwedagon Pagoda", latitude: 19.75, longitude: 96.1, region: .southeastAsia),
        "Cambodia": CountryProfile(universities: ["University of Angkor", "Mekong Institute"], salaryMultiplier: 0.15, capital: "Phnom Penh", language: "Khmer", currency: "Cambodian Riel", landmark: "Angkor Wat", latitude: 11.55, longitude: 104.92, region: .southeastAsia),

        // Middle East / North Africa
        "Egypt": CountryProfile(universities: ["Nile Valley University", "Pyramid Institute of Technology"], salaryMultiplier: 0.2, capital: "Cairo", language: "Arabic", currency: "Egyptian Pound", landmark: "Pyramids of Giza", latitude: 30.04, longitude: 31.24, region: .middleEastNorthAfrica),
        "Morocco": CountryProfile(universities: ["University of Atlas", "Casbah Institute"], salaryMultiplier: 0.25, capital: "Rabat", language: "Arabic", currency: "Moroccan Dirham", landmark: "Hassan II Mosque", latitude: 34.02, longitude: -6.84, region: .middleEastNorthAfrica),
        "Algeria": CountryProfile(universities: ["University of the Sahara Coast", "Casbah Institute of Technology"], salaryMultiplier: 0.25, capital: "Algiers", language: "Arabic", currency: "Algerian Dinar", landmark: "Casbah of Algiers", latitude: 36.75, longitude: 3.06, region: .middleEastNorthAfrica),
        "Tunisia": CountryProfile(universities: ["University of Carthage Coast", "Medina Institute"], salaryMultiplier: 0.22, capital: "Tunis", language: "Arabic", currency: "Tunisian Dinar", landmark: "Amphitheatre of El Jem", latitude: 36.8, longitude: 10.18, region: .middleEastNorthAfrica),
        "Saudi Arabia": CountryProfile(universities: ["University of the Hejaz", "Riyadh Institute of Technology"], salaryMultiplier: 0.7, capital: "Riyadh", language: "Arabic", currency: "Saudi Riyal", landmark: "Masmak Fortress", latitude: 24.71, longitude: 46.68, region: .middleEastNorthAfrica),
        "United Arab Emirates": CountryProfile(universities: ["University of the Gulf", "Desert Coast Institute of Technology"], salaryMultiplier: 0.95, capital: "Abu Dhabi", language: "Arabic", currency: "UAE Dirham", landmark: "Burj Khalifa", latitude: 24.45, longitude: 54.38, region: .middleEastNorthAfrica),
        "Israel": CountryProfile(universities: ["University of the Galilee", "Mediterranean Institute of Technology"], salaryMultiplier: 0.85, capital: "Jerusalem", language: "Hebrew", currency: "Israeli Shekel", landmark: "Western Wall", latitude: 31.78, longitude: 35.22, region: .middleEastNorthAfrica),
        "Turkey": CountryProfile(universities: ["University of Anatolia", "Bosphorus Institute"], salaryMultiplier: 0.35, capital: "Ankara", language: "Turkish", currency: "Turkish Lira", landmark: "Hagia Sophia", latitude: 39.93, longitude: 32.86, region: .middleEastNorthAfrica),
        "Iran": CountryProfile(universities: ["University of Persepolis", "Alborz Institute of Technology"], salaryMultiplier: 0.25, capital: "Tehran", language: "Persian", currency: "Iranian Rial", landmark: "Persepolis", latitude: 35.69, longitude: 51.39, region: .middleEastNorthAfrica),

        // Sub-Saharan Africa
        "South Africa": CountryProfile(universities: ["Cape Ridge University", "Savanna State University"], salaryMultiplier: 0.3, capital: "Pretoria", language: "English", currency: "South African Rand", landmark: "Table Mountain", latitude: -25.7, longitude: 28.2, region: .subSaharanAfrica),
        "Nigeria": CountryProfile(universities: ["Lagos Coast University", "Savannah Institute"], salaryMultiplier: 0.15, capital: "Abuja", language: "English", currency: "Nigerian Naira", landmark: "Zuma Rock", latitude: 9.08, longitude: 7.49, region: .subSaharanAfrica),
        "Kenya": CountryProfile(universities: ["University of the Rift Valley", "Nairobi Institute of Technology"], salaryMultiplier: 0.15, capital: "Nairobi", language: "Swahili", currency: "Kenyan Shilling", landmark: "Maasai Mara", latitude: -1.29, longitude: 36.82, region: .subSaharanAfrica),
        "Ghana": CountryProfile(universities: ["University of the Gold Coast", "Accra Institute of Technology"], salaryMultiplier: 0.15, capital: "Accra", language: "English", currency: "Ghanaian Cedi", landmark: "Cape Coast Castle", latitude: 5.6, longitude: -0.19, region: .subSaharanAfrica),
        "Ethiopia": CountryProfile(universities: ["University of the Highlands", "Addis Institute of Technology"], salaryMultiplier: 0.1, capital: "Addis Ababa", language: "Amharic", currency: "Ethiopian Birr", landmark: "Lalibela Churches", latitude: 9.03, longitude: 38.74, region: .subSaharanAfrica),
        "Tanzania": CountryProfile(universities: ["University of Kilimanjaro", "Zanzibar Coast Institute"], salaryMultiplier: 0.12, capital: "Dodoma", language: "Swahili", currency: "Tanzanian Shilling", landmark: "Mount Kilimanjaro", latitude: -6.16, longitude: 35.75, region: .subSaharanAfrica),
        "Senegal": CountryProfile(universities: ["University of Dakar Coast", "Gorée Institute"], salaryMultiplier: 0.15, capital: "Dakar", language: "French", currency: "West African CFA Franc", landmark: "Gorée Island", latitude: 14.72, longitude: -17.47, region: .subSaharanAfrica),
        "Ivory Coast": CountryProfile(universities: ["University of the Ivory Coast", "Yamoussoukro Institute of Technology"], salaryMultiplier: 0.15, capital: "Yamoussoukro", language: "French", currency: "West African CFA Franc", landmark: "Basilica of Our Lady of Peace", latitude: 6.83, longitude: -5.28, region: .subSaharanAfrica),
        "Cameroon": CountryProfile(universities: ["University of the Littoral", "Yaoundé Institute of Technology"], salaryMultiplier: 0.13, capital: "Yaoundé", language: "French", currency: "Central African CFA Franc", landmark: "Mount Cameroon", latitude: 3.87, longitude: 11.52, region: .subSaharanAfrica),
        "Zimbabwe": CountryProfile(universities: ["University of the Zambezi", "Harare Institute of Technology"], salaryMultiplier: 0.1, capital: "Harare", language: "English", currency: "Zimbabwean Dollar", landmark: "Victoria Falls", latitude: -17.83, longitude: 31.05, region: .subSaharanAfrica),
        "Zambia": CountryProfile(universities: ["University of the Copperbelt", "Lusaka Institute of Technology"], salaryMultiplier: 0.12, capital: "Lusaka", language: "English", currency: "Zambian Kwacha", landmark: "Victoria Falls", latitude: -15.39, longitude: 28.32, region: .subSaharanAfrica),
        "Uganda": CountryProfile(universities: ["University of the Great Lakes", "Kampala Institute of Technology"], salaryMultiplier: 0.1, capital: "Kampala", language: "English", currency: "Ugandan Shilling", landmark: "Lake Victoria", latitude: 0.35, longitude: 32.58, region: .subSaharanAfrica),

        // Latin America & Caribbean
        "Brazil": CountryProfile(universities: ["Universidade Costa Verde", "Instituto Rio Novo"], salaryMultiplier: 0.35, capital: "Brasília", language: "Portuguese", currency: "Brazilian Real", landmark: "Christ the Redeemer", latitude: -15.8, longitude: -47.9, region: .latinAmerica),
        "Mexico": CountryProfile(universities: ["Universidad del Sol", "Instituto Azteca"], salaryMultiplier: 0.28, capital: "Mexico City", language: "Spanish", currency: "Mexican Peso", landmark: "Chichén Itzá", latitude: 19.43, longitude: -99.13, region: .latinAmerica),
        "Argentina": CountryProfile(universities: ["Universidad de la Pampa", "Instituto Patagonia"], salaryMultiplier: 0.3, capital: "Buenos Aires", language: "Spanish", currency: "Argentine Peso", landmark: "Perito Moreno Glacier", latitude: -34.6, longitude: -58.4, region: .latinAmerica),
        "Chile": CountryProfile(universities: ["Universidad de los Andes Sur", "Instituto Atacama"], salaryMultiplier: 0.5, capital: "Santiago", language: "Spanish", currency: "Chilean Peso", landmark: "Easter Island Moai", latitude: -33.45, longitude: -70.67, region: .latinAmerica),
        "Colombia": CountryProfile(universities: ["Universidad del Caribe Sur", "Instituto Andino"], salaryMultiplier: 0.3, capital: "Bogotá", language: "Spanish", currency: "Colombian Peso", landmark: "Cartagena Old Town", latitude: 4.71, longitude: -74.07, region: .latinAmerica),
        "Peru": CountryProfile(universities: ["Universidad del Inca", "Instituto Andes Norte"], salaryMultiplier: 0.28, capital: "Lima", language: "Spanish", currency: "Peruvian Sol", landmark: "Machu Picchu", latitude: -12.05, longitude: -77.04, region: .latinAmerica),
        "Venezuela": CountryProfile(universities: ["Universidad del Orinoco", "Instituto Caribe"], salaryMultiplier: 0.12, capital: "Caracas", language: "Spanish", currency: "Venezuelan Bolívar", landmark: "Angel Falls", latitude: 10.49, longitude: -66.88, region: .latinAmerica),
        "Ecuador": CountryProfile(universities: ["Universidad de las Islas", "Instituto Andino Norte"], salaryMultiplier: 0.25, capital: "Quito", language: "Spanish", currency: "US Dollar", landmark: "Galápagos Islands", latitude: -0.23, longitude: -78.52, region: .latinAmerica),
        "Uruguay": CountryProfile(universities: ["Universidad del Plata", "Instituto Costa Este"], salaryMultiplier: 0.55, capital: "Montevideo", language: "Spanish", currency: "Uruguayan Peso", landmark: "Palacio Salvo", latitude: -34.9, longitude: -56.16, region: .latinAmerica),
        "Paraguay": CountryProfile(universities: ["Universidad del Chaco", "Instituto Guaraní"], salaryMultiplier: 0.25, capital: "Asunción", language: "Spanish", currency: "Paraguayan Guaraní", landmark: "Itaipu Dam", latitude: -25.3, longitude: -57.64, region: .latinAmerica),
        "Bolivia": CountryProfile(universities: ["Universidad del Altiplano", "Instituto Salar"], salaryMultiplier: 0.2, capital: "Sucre", language: "Spanish", currency: "Bolivian Boliviano", landmark: "Salar de Uyuni", latitude: -19.03, longitude: -65.26, region: .latinAmerica),
        "Cuba": CountryProfile(universities: ["Universidad de la Habana Vieja", "Instituto del Caribe"], salaryMultiplier: 0.1, capital: "Havana", language: "Spanish", currency: "Cuban Peso", landmark: "El Malecón", latitude: 23.13, longitude: -82.38, region: .latinAmerica),
        "Dominican Republic": CountryProfile(universities: ["Universidad del Caribe Este", "Instituto Colonial"], salaryMultiplier: 0.25, capital: "Santo Domingo", language: "Spanish", currency: "Dominican Peso", landmark: "Zona Colonial", latitude: 18.49, longitude: -69.93, region: .latinAmerica),
        "Costa Rica": CountryProfile(universities: ["Universidad de la Pura Vida", "Instituto Volcánico"], salaryMultiplier: 0.4, capital: "San José", language: "Spanish", currency: "Costa Rican Colón", landmark: "Arenal Volcano", latitude: 9.93, longitude: -84.08, region: .latinAmerica),
        "Panama": CountryProfile(universities: ["Universidad del Canal", "Instituto Istmo"], salaryMultiplier: 0.45, capital: "Panama City", language: "Spanish", currency: "Panamanian Balboa", landmark: "Panama Canal", latitude: 8.98, longitude: -79.52, region: .latinAmerica),
        "Guatemala": CountryProfile(universities: ["Universidad del Maya", "Instituto Volcán Norte"], salaryMultiplier: 0.2, capital: "Guatemala City", language: "Spanish", currency: "Guatemalan Quetzal", landmark: "Tikal", latitude: 14.63, longitude: -90.51, region: .latinAmerica),
        "Jamaica": CountryProfile(universities: ["University of the Blue Mountains", "Kingston Coast College"], salaryMultiplier: 0.2, capital: "Kingston", language: "English", currency: "Jamaican Dollar", landmark: "Dunn's River Falls", latitude: 17.97, longitude: -76.79, region: .latinAmerica),
    ]

    static func profile(for country: String) -> CountryProfile {
        profiles[country] ?? CountryProfile(universities: ["State University", "City College"], salaryMultiplier: 0.8, capital: "Capital City", language: "Local language", currency: "Local currency", landmark: "a famous local landmark", latitude: 0, longitude: 0, region: .angloWestern)
    }

    static func allCountryNames() -> [String] {
        Array(profiles.keys).sorted()
    }
}
