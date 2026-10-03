import Foundation

/// A flavor vignette for the passive pocket-money event that fires for
/// children and teens each year in `GameViewModel.yearlyPocketMoney` — purely
/// narrative, since the odds and the dollar amount are already decided
/// before one of these is picked. `regions` of `nil` means it fits anywhere;
/// a non-nil set limits the vignette to those cultures for a bit of
/// "this looks different depending where you grew up" variety.
struct YouthJobVignette {
    let regions: Set<CultureRegion>?
    let text: (Character, Int) -> String

    init(regions: Set<CultureRegion>? = nil, text: @escaping (Character, Int) -> String) {
        self.regions = regions
        self.text = text
    }
}

enum YouthJobData {
    /// Roughly ages 6-12.
    static let childVignettes: [YouthJobVignette] = [
        YouthJobVignette { _, amount in "You sold lemonade on the corner and made $\(amount)." },
        YouthJobVignette { _, amount in "You ran errands for a neighbor and earned $\(amount)." },
        YouthJobVignette { _, amount in "You walked the neighborhood dogs and made $\(amount)." },
        YouthJobVignette { _, amount in "You washed cars on the street and earned $\(amount)." },
        YouthJobVignette { _, amount in "You collected bottles and cans for the deposit refund and made $\(amount)." },
        YouthJobVignette { _, amount in "You helped sell crafts at a community fair and came home with $\(amount)." },
        YouthJobVignette { _, amount in "You did extra chores around the house and were paid $\(amount)." },
        YouthJobVignette { _, amount in "You babysat a younger cousin for an afternoon and earned $\(amount)." },
        YouthJobVignette { _, amount in "You helped out at a relative's shop after school and were given $\(amount)." },
        YouthJobVignette { _, amount in "You sold old toys at a yard sale and made $\(amount)." },
        YouthJobVignette { _, amount in "You raked leaves for a neighbor and earned $\(amount)." },
        YouthJobVignette { _, amount in "You tutored a younger kid on the block and were paid $\(amount)." },
        YouthJobVignette { _, amount in "You helped organize a bake sale and took home $\(amount)." },
        YouthJobVignette { _, amount in "You fed a neighbor's pets while they were away and earned $\(amount)." },

        YouthJobVignette(regions: [.angloWestern]) { _, amount in "You earned a badge and a little allowance at Trailhead Scouts, $\(amount)." },
        YouthJobVignette(regions: [.latinEurope]) { _, amount in "You helped out at a family bakery after school and were given $\(amount)." },
        YouthJobVignette(regions: [.germanicNordic]) { _, amount in "You sorted bottles at the recycling depot for the deposit and made $\(amount)." },
        YouthJobVignette(regions: [.slavicEastEurope]) { _, amount in "You helped your grandparents sell vegetables at the market stall and earned $\(amount)." },
        YouthJobVignette(regions: [.eastAsia]) { _, amount in "You helped out at the family convenience store after school and were given $\(amount)." },
        YouthJobVignette(regions: [.southAsia]) { _, amount in "You helped decorate for a neighborhood festival and were tipped $\(amount)." },
        YouthJobVignette(regions: [.southeastAsia]) { _, amount in "You helped out at the family food stall after school and were given $\(amount)." },
        YouthJobVignette(regions: [.middleEastNorthAfrica]) { _, amount in "You helped out at a family shop in the market and were given $\(amount)." },
        YouthJobVignette(regions: [.subSaharanAfrica]) { _, amount in "You helped sell goods at the family market stall and earned $\(amount)." },
        YouthJobVignette(regions: [.latinAmerica]) { _, amount in "You helped wash windshields at the local intersection and earned $\(amount)." },
    ]

    /// Roughly ages 13-17 — still informal, nothing that needs a real interview.
    static let teenVignettes: [YouthJobVignette] = [
        YouthJobVignette { _, amount in "You mowed lawns around the neighborhood and made $\(amount)." },
        YouthJobVignette { _, amount in "You picked up an under-the-table shift at a local café and earned $\(amount)." },
        YouthJobVignette { _, amount in "You delivered newspapers before school and made $\(amount)." },
        YouthJobVignette { _, amount in "You tutored younger students after school and earned $\(amount)." },
        YouthJobVignette { _, amount in "You helped out at a relative's shop on weekends and were paid $\(amount)." },
        YouthJobVignette { _, amount in "You did some freelance gig work online and made $\(amount)." },
        YouthJobVignette { _, amount in "You washed cars at a charity fundraiser and earned $\(amount)." },
        YouthJobVignette { _, amount in "You picked up seasonal farm work for a weekend and made $\(amount)." },
        YouthJobVignette { _, amount in "You worked the coat check at a local event and earned $\(amount)." },
        YouthJobVignette { _, amount in "You sold handmade bracelets and keychains and made $\(amount)." },
        YouthJobVignette { _, amount in "You babysat for a family down the street and earned $\(amount)." },
        YouthJobVignette { _, amount in "You helped a neighbor move furniture and were paid $\(amount)." },
        YouthJobVignette { _, amount in "You busked downtown for an afternoon and made $\(amount)." },
        YouthJobVignette { _, amount in "You did yard work for an elderly neighbor and earned $\(amount)." },

        YouthJobVignette(regions: [.angloWestern]) { _, amount in "You earned a leadership badge and stipend running activities at Trailhead Scouts, $\(amount)." },
        YouthJobVignette(regions: [.latinEurope]) { _, amount in "You worked weekend shifts at a family café and earned $\(amount)." },
        YouthJobVignette(regions: [.germanicNordic]) { _, amount in "You took on a proper paper round across the neighborhood and earned $\(amount)." },
        YouthJobVignette(regions: [.slavicEastEurope]) { _, amount in "You helped at the family garden plot's market stall over the weekend and earned $\(amount)." },
        YouthJobVignette(regions: [.eastAsia]) { _, amount in "You tutored younger students at a local cram school and earned $\(amount)." },
        YouthJobVignette(regions: [.southAsia]) { _, amount in "You tutored neighborhood kids in math and were paid $\(amount)." },
        YouthJobVignette(regions: [.southeastAsia]) { _, amount in "You picked up weekend shifts helping at the family stall and earned $\(amount)." },
        YouthJobVignette(regions: [.middleEastNorthAfrica]) { _, amount in "You worked weekends helping at a family shop and earned $\(amount)." },
        YouthJobVignette(regions: [.subSaharanAfrica]) { _, amount in "You took on weekend work helping at a relative's stall and earned $\(amount)." },
        YouthJobVignette(regions: [.latinAmerica]) { _, amount in "You picked up weekend shifts washing cars and earned $\(amount)." },
    ]

    static func text(for character: Character, amount: Int) -> String {
        let region = CountryData.profile(for: character.country).region
        let pool = character.age <= 12 ? childVignettes : teenVignettes
        let matching = pool.filter { $0.regions == nil || $0.regions!.contains(region) }
        let vignette = matching.randomElement() ?? pool[0]
        return vignette.text(character, amount)
    }
}
