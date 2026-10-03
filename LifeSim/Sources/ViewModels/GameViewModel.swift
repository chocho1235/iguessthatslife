import Foundation

@MainActor
final class GameViewModel: ObservableObject {
    @Published var character: Character? {
        didSet {
            if let character {
                SaveManager.save(character)
            }
        }
    }
    @Published var yearLog: [LogEntry] = []
    @Published var isGameOver: Bool = false
    @Published var pendingSocialEvent: SocialEvent?
    @Published var pendingLegalTrouble: LegalTrouble?
    /// Bumped every time the character is physically attacked — views watch
    /// this to flash the screen red and fire a haptic, independent of
    /// whatever log text or sound already describes the moment.
    @Published var attackTrigger: Int = 0

    init() {
        if let saved = SaveManager.load() {
            character = saved
            isGameOver = !saved.isAlive
            yearLog = [LogEntry(text: "Welcome back, \(saved.firstName). Picking up where you left off at age \(saved.age).", isAlert: false)]
        }
    }

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
        pendingSocialEvent = nil
        let gender: Gender = Bool.random() ? .male : .female
        let country = NameData.randomCountry()
        let region = CountryData.profile(for: country).region
        let firstName = NameData.randomFirstName(for: gender, region: region)
        let lastName = NameData.randomLastName(region: region)

        var family: [FamilyMember] = [
            FamilyMember(name: "\(NameData.randomFirstName(for: .female, region: region)) \(lastName)", relation: .mother, relationship: Int.random(in: 60...95)),
            FamilyMember(name: "\(NameData.randomFirstName(for: .male, region: region)) \(lastName)", relation: .father, relationship: Int.random(in: 60...95)),
        ]
        if Bool.random() {
            let siblingGender: Gender = Bool.random() ? .male : .female
            family.append(
                FamilyMember(
                    name: "\(NameData.randomFirstName(for: siblingGender, region: region)) \(lastName)",
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
            cash: 0,
            stockPrices: StockData.startingPrices()
        )
        yearLog = [LogEntry(text: "You were born in \(country) to \(family[0].name) and \(family[1].name).", isAlert: false)]
        isGameOver = false
    }

    func ageUp() {
        guard pendingSocialEvent == nil, pendingLegalTrouble == nil, var current = character, current.isAlive else { return }
        current.age += 1
        resetRelationshipHistories(&current)

        if current.isInJail {
            var log: [LogEntry] = []
            applyYearlyFinances(&current, log: &log)
            handleJailYear(&current, log: &log)
            current.policeHeat -= 12
            handleConditions(&current, log: &log)
            applyNaturalDrift(&current)
            checkForDeath(&current, log: &log)
            character = current
            yearLog = log
            if !current.isAlive {
                isGameOver = true
                SoundManager.shared.play(.death)
            } else {
                SoundManager.shared.play(.ageUp)
            }
            return
        }

        let stage = current.stage
        let eventCount = Int.random(in: 1...3)
        var log: [LogEntry] = []
        applyYearlyFinances(&current, log: &log)

        if let allowance = yearlyPocketMoney(for: current) {
            current.cash += allowance
            log.append(LogEntry(text: pocketMoneyText(for: current, amount: allowance), isAlert: false))
        }

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
            let scaledCashDelta = event.cashDelta == 0 ? 0 : (event.cashDelta > 0 ? localized(event.cashDelta, for: current) : -localized(-event.cashDelta, for: current))
            if scaledCashDelta != 0 {
                current.cash = max(0, current.cash + scaledCashDelta)
            }
            if let conditionID = event.grantsConditionID {
                grantCondition(&current, id: conditionID)
                if conditionID == "stab_wound" || conditionID == "gunshot_wound" {
                    attackTrigger += 1
                }
            }

            var entry = event.text(current)
            if scaledCashDelta > 0 {
                entry += " (+$\(scaledCashDelta))"
            } else if scaledCashDelta < 0 {
                entry += " (-$\(abs(scaledCashDelta)))"
            }
            let isAlert = event.healthDelta < 0 || scaledCashDelta < 0 || event.relationshipDelta < 0 || event.grantsConditionID != nil
            log.append(LogEntry(text: entry, isAlert: isAlert))
        }

        handleFriends(&current, log: &log)
        handlePartner(&current, log: &log)
        handleChildren(&current, log: &log)
        handleRelationshipEvents(&current, log: &log)
        handleConditions(&current, log: &log)
        rollForVision(&current, log: &log)
        handleCareer(&current, log: &log)
        handlePolicing(&current, log: &log)
        applyNaturalDrift(&current)
        checkForDeath(&current, log: &log)

        character = current
        yearLog = log
        if !current.isAlive {
            isGameOver = true
            SoundManager.shared.play(.death)
        } else if pendingLegalTrouble != nil {
            SoundManager.shared.playSequence([.ageUp, .alert])
        } else if pendingSocialEvent != nil {
            // A decision popup is about to appear — follow the normal
            // age-up sound with a distinct notification chime.
            SoundManager.shared.playSequence([.ageUp, .notify])
        } else {
            SoundManager.shared.play(.ageUp)
        }
    }

    func resolveSocialEvent(accepted: Bool) {
        guard let event = pendingSocialEvent, var current = character else { return }
        pendingSocialEvent = nil

        let result: LogEntry
        switch event.kind {
        case .moneyRequest:
            result = resolveMoneyRequest(event, accepted: accepted, character: &current)
        case .familyEmergency:
            result = resolveFamilyEmergency(event, accepted: accepted, character: &current)
        case .fightBackup:
            result = resolveFightBackup(event, accepted: accepted, character: &current)
        case .hangoutInvite:
            result = resolveHangoutInvite(event, accepted: accepted, character: &current)
        case .riskyScheme:
            result = resolveRiskyScheme(event, accepted: accepted, character: &current)
        case .coverStory:
            result = resolveCoverStory(event, accepted: accepted, character: &current)
        case .gangRecruitment:
            result = resolveGangRecruitment(event, accepted: accepted, character: &current)
        case .jobOffer:
            result = resolveJobOffer(event, accepted: accepted, character: &current)
        case .gangHeist:
            result = resolveGangHeist(event, accepted: accepted, character: &current)
        }

        var log = yearLog
        log.append(result)
        checkForDeath(&current, log: &log)
        character = current
        yearLog = log
        if !current.isAlive {
            isGameOver = true
            SoundManager.shared.play(.death)
        }
    }

    /// Scales a flat, US-pegged dollar figure to the character's local
    /// economy — the same approach already used for job wages and tuition.
    private func localized(_ amount: Int, for character: Character) -> Int {
        max(0, Int(Double(amount) * CountryData.profile(for: character.country).salaryMultiplier))
    }

    private func yearlyPocketMoney(for character: Character) -> Int? {
        let raw: Int?
        switch character.age {
        case 0...5:
            raw = nil
        case 6...10:
            raw = Double.random(in: 0...1) < 0.45 ? Int.random(in: 1...5) : nil
        case 11...12:
            raw = Double.random(in: 0...1) < 0.60 ? Int.random(in: 3...10) : nil
        case 13...15:
            raw = Double.random(in: 0...1) < 0.70 ? Int.random(in: 5...18) : nil
        case 16...17:
            raw = Double.random(in: 0...1) < 0.45 ? Int.random(in: 10...35) : nil
        default:
            raw = nil
        }
        return raw.map { localized($0, for: character) }
    }

    private func pocketMoneyText(for character: Character, amount: Int) -> String {
        guard (6...17).contains(character.age) else { return "You received $\(amount)." }
        return YouthJobData.text(for: character, amount: amount)
    }

    private static let savingsInterestRate = 0.04
    /// Stocks drift up slightly on average so holding through the noise
    /// tends to pay off, same as yearly compounding on savings.
    private static let stockDriftRate = 0.02

    /// Grows savings and rolls the market forward by one year. Runs for
    /// every year that passes, prison included — money keeps working for
    /// you (or against you) whether or not you're free to spend it.
    private func applyYearlyFinances(_ character: inout Character, log: inout [LogEntry]) {
        if character.bankBalance > 0 {
            let interest = max(1, Int(Double(character.bankBalance) * Self.savingsInterestRate))
            character.bankBalance += interest
            log.append(LogEntry(text: "Your savings earned $\(interest) in interest.", isAlert: false))
        }

        for stock in StockData.all {
            let oldPrice = character.stockPrices[stock.id] ?? stock.basePrice
            let swing = Double.random(in: -stock.volatility...stock.volatility)
            let newPrice = max(1.0, oldPrice * (1 + Self.stockDriftRate + swing))
            character.stockPrices[stock.id] = newPrice

            let shares = character.stockHoldings[stock.id] ?? 0
            guard shares > 0, oldPrice > 0 else { continue }
            let percentChange = (newPrice - oldPrice) / oldPrice
            guard abs(percentChange) >= 0.15 else { continue }
            let direction = percentChange > 0 ? "jumped" : "dropped"
            let percentText = String(format: "%.0f", abs(percentChange) * 100)
            log.append(LogEntry(text: "\(stock.symbol) \(direction) \(percentText)% to $\(String(format: "%.2f", newPrice))/share.", isAlert: percentChange < 0))
        }

        handleAssets(&character, log: &log)
    }

    // MARK: - Assets

    /// The asset's sticker price in the character's local economy.
    func localPrice(of asset: Asset) -> Int {
        guard let current = character else { return asset.price }
        return localized(asset.price, for: current)
    }

    func localUpkeep(of asset: Asset) -> Int {
        guard let current = character else { return asset.yearlyUpkeep }
        return localized(asset.yearlyUpkeep, for: current)
    }

    func mortgageDownPayment(for asset: Asset) -> Int {
        Int(Double(localPrice(of: asset)) * AssetData.mortgageDownPayment)
    }

    /// Everything you own minus everything you owe.
    var netWorth: Int {
        guard let current = character else { return 0 }
        let stocks = StockData.all.reduce(0.0) { total, stock in
            total + Double(current.stockHoldings[stock.id] ?? 0) * stockPrice(for: stock, character: current)
        }
        let equity = current.ownedAssets.reduce(0) { $0 + $1.equity }
        return current.cash + current.bankBalance + Int(stocks) + equity
    }

    /// Why this can't be bought right now, or nil if it can.
    func assetPurchaseBlocker(_ asset: Asset, mortgage: Bool) -> String? {
        guard let current = character else { return "Start a life first." }
        guard current.age >= asset.kind.minimumAge else { return "You must be \(asset.kind.minimumAge) to buy this." }
        guard !current.ownedAssets.contains(where: { $0.assetID == asset.id }) else { return "You already own one." }
        let price = localized(asset.price, for: current)
        if mortgage {
            guard asset.kind.allowsMortgage else { return "You can't get a mortgage for this." }
            guard let job = current.job, !job.isPartTime else { return "The bank wants to see a full-time job before giving you a mortgage." }
            let salary = Int(Double(job.baseSalary) * CountryData.profile(for: current.country).salaryMultiplier)
            let loan = price - mortgageDownPayment(for: asset)
            let payment = Int(Double(loan) * AssetData.mortgagePaymentRate)
            guard payment <= salary / 2 else { return "The bank says your salary is too low. Payments would be $\(payment)/yr." }
            guard current.cash >= mortgageDownPayment(for: asset) else { return "You need $\(mortgageDownPayment(for: asset)) cash for the down payment." }
        } else {
            guard current.cash >= price else { return "You need $\(price) in cash." }
        }
        return nil
    }

    @discardableResult
    func buyAsset(_ asset: Asset, mortgage: Bool = false) -> String {
        if let blocker = assetPurchaseBlocker(asset, mortgage: mortgage) { return blocker }
        guard var current = character else { return "" }
        let price = localized(asset.price, for: current)
        let upkeep = localized(asset.yearlyUpkeep, for: current)

        var owned = OwnedAsset(assetID: asset.id, purchasePrice: price, value: price, upkeep: upkeep)
        let text: String
        if mortgage {
            let down = mortgageDownPayment(for: asset)
            current.cash -= down
            owned.loanRemaining = price - down
            owned.yearlyPayment = Int(Double(owned.loanRemaining) * AssetData.mortgagePaymentRate)
            text = "You bought a \(asset.name) with $\(down) down and a mortgage of $\(owned.loanRemaining). Payments are $\(owned.yearlyPayment) a year."
        } else {
            current.cash -= price
            text = "You bought a \(asset.name) for $\(price)!"
        }
        current.ownedAssets.append(owned)
        current.stats.adjust(happiness: Int.random(in: 2...6))
        character = current
        var log = yearLog
        log.append(LogEntry(text: text, isAlert: false))
        yearLog = log
        SoundManager.shared.playSequence([.cash, .achievement])
        return text
    }

    @discardableResult
    func sellAsset(_ ownedID: UUID) -> String {
        guard var current = character,
              let index = current.ownedAssets.firstIndex(where: { $0.id == ownedID }) else { return "" }
        let owned = current.ownedAssets[index]
        let name = owned.asset?.name ?? "asset"
        let proceeds = owned.equity
        guard current.cash + proceeds >= 0 else {
            return "You owe more on the \(name) than it's worth. You need $\(-proceeds) cash to cover the difference."
        }
        current.cash += proceeds
        current.ownedAssets.remove(at: index)
        character = current
        SoundManager.shared.play(.cash)
        let text: String
        if owned.loanRemaining > 0 {
            text = "You sold your \(name) for $\(owned.value). After paying off the mortgage you kept $\(proceeds)."
        } else {
            text = "You sold your \(name) for $\(proceeds)."
        }
        var log = yearLog
        log.append(LogEntry(text: text, isAlert: false))
        yearLog = log
        return text
    }

    /// Takes money from cash first, then savings. Returns false if there
    /// isn't enough between the two (and takes nothing).
    private func pay(_ amount: Int, from character: inout Character) -> Bool {
        guard amount > 0 else { return true }
        guard character.cash + character.bankBalance >= amount else { return false }
        let fromCash = min(character.cash, amount)
        character.cash -= fromCash
        character.bankBalance -= amount - fromCash
        return true
    }

    /// Yearly: values drift, upkeep and mortgage payments come due, owners
    /// get a happiness bump and the odd thing goes wrong.
    private func handleAssets(_ character: inout Character, log: inout [LogEntry]) {
        guard !character.ownedAssets.isEmpty else { return }
        let name = character.firstName
        var kept: [OwnedAsset] = []
        var happiness = 0
        var hadEvent = false

        for var owned in character.ownedAssets {
            guard let asset = owned.asset else { continue }
            owned.yearsOwned += 1
            let drift = asset.yearlyValueChange + Double.random(in: -0.04...0.04)
            owned.value = max(0, Int(Double(owned.value) * (1 + drift)))

            // Mortgage
            if owned.loanRemaining > 0 {
                let owed = Int(Double(owned.loanRemaining) * (1 + AssetData.mortgageInterestRate))
                let payment = min(owned.yearlyPayment, owed)
                if pay(payment, from: &character) {
                    owned.loanRemaining = owed - payment
                    if owned.loanRemaining <= 0 {
                        owned.loanRemaining = 0
                        log.append(LogEntry(text: "\(name) paid off the mortgage on their \(asset.name)! It's all theirs now.", isAlert: false))
                    }
                } else {
                    let leftover = max(0, Int(Double(owned.value) * 0.7) - owned.loanRemaining)
                    character.cash += leftover
                    character.stats.adjust(happiness: -Int.random(in: 8...15))
                    log.append(LogEntry(text: "\(name) couldn't make the $\(payment) mortgage payment. The bank foreclosed on the \(asset.name)\(leftover > 0 ? " and \(name) got $\(leftover) back" : "").", isAlert: true))
                    SoundManager.shared.play(.sad)
                    continue
                }
            }

            // Upkeep
            if !pay(owned.upkeep, from: &character) {
                let salvage = max(0, owned.value / 2 - owned.loanRemaining)
                character.cash += salvage
                character.stats.adjust(happiness: -Int.random(in: 4...10))
                log.append(LogEntry(text: "\(name) couldn't afford the $\(owned.upkeep) upkeep on their \(asset.name), so it was repossessed and sold off for $\(salvage).", isAlert: true))
                continue
            }

            // At most one mishap a year across everything you own.
            if !hadEvent, let mishap = assetMishap(&owned, asset: asset, character: &character) {
                hadEvent = true
                log.append(mishap)
            }

            happiness += asset.happiness
            kept.append(owned)
        }

        character.ownedAssets = kept
        if happiness > 0 {
            character.stats.adjust(happiness: min(8, happiness / 2 + 1))
        }
    }

    private func assetMishap(_ owned: inout OwnedAsset, asset: Asset, character: inout Character) -> LogEntry? {
        let name = character.firstName
        let roll = Double.random(in: 0...1)
        switch asset.kind {
        case .car, .motorcycle:
            let crashChance = asset.kind == .motorcycle ? 0.06 : 0.03
            guard roll < crashChance else { return nil }
            owned.value = Int(Double(owned.value) * 0.7)
            grantCondition(&character, id: character.stage == .senior ? "minor_injury" : (Bool.random() ? "broken_arm" : "minor_injury"))
            attackTrigger += 1
            SoundManager.shared.play(.ouch)
            return LogEntry(text: "\(name) crashed their \(asset.name). They got hurt, and the \(asset.name) lost a big chunk of its value.", isAlert: true)
        case .house:
            guard roll < 0.04 else { return nil }
            if Bool.random() {
                let stolen = min(character.cash, localized(Int.random(in: 300...4_000), for: character))
                character.cash -= stolen
                character.stats.adjust(happiness: -Int.random(in: 3...8))
                SoundManager.shared.play(.glassBreak)
                return LogEntry(text: "Burglars broke into \(name)'s \(asset.name) and took $\(stolen) worth of stuff.", isAlert: true)
            }
            let repair = owned.upkeep
            _ = pay(repair, from: &character)
            SoundManager.shared.play(.alert)
            return LogEntry(text: "A storm damaged \(name)'s \(asset.name). Repairs cost $\(repair).", isAlert: true)
        case .boat:
            guard roll < 0.03 else { return nil }
            owned.value = Int(Double(owned.value) * 0.85)
            SoundManager.shared.play(.alert)
            return LogEntry(text: "\(name)'s \(asset.name) got caught in a storm and took some damage.", isAlert: true)
        case .aircraft:
            guard roll < 0.015 else { return nil }
            owned.value = Int(Double(owned.value) * 0.8)
            grantCondition(&character, id: "minor_injury")
            SoundManager.shared.play(.ouch)
            return LogEntry(text: "\(name)'s \(asset.name) had to make an emergency landing. Everyone walked away, barely.", isAlert: true)
        }
    }

    func stockPrice(for stock: Stock, character: Character) -> Double {
        character.stockPrices[stock.id] ?? stock.basePrice
    }

    @discardableResult
    func depositToBank(_ amount: Int) -> String {
        guard var current = character, amount > 0 else { return "" }
        guard current.cash >= amount else { return "You don't have $\(amount) in cash." }
        current.cash -= amount
        current.bankBalance += amount
        character = current
        SoundManager.shared.play(.cash)
        return "Deposited $\(amount) into savings."
    }

    @discardableResult
    func withdrawFromBank(_ amount: Int) -> String {
        guard var current = character, amount > 0 else { return "" }
        guard current.bankBalance >= amount else { return "You don't have $\(amount) in savings." }
        current.bankBalance -= amount
        current.cash += amount
        character = current
        SoundManager.shared.play(.cash)
        return "Withdrew $\(amount) from savings."
    }

    @discardableResult
    func buyStock(_ stock: Stock, shares: Int) -> String {
        guard var current = character, shares > 0 else { return "" }
        let price = stockPrice(for: stock, character: current)
        let cost = max(1, Int((price * Double(shares)).rounded(.up)))
        guard current.cash >= cost else { return "You need $\(cost) to buy \(shares) share\(shares == 1 ? "" : "s") of \(stock.symbol)." }
        current.cash -= cost
        current.stockHoldings[stock.id, default: 0] += shares
        character = current
        SoundManager.shared.play(.cash)
        return "Bought \(shares) share\(shares == 1 ? "" : "s") of \(stock.symbol) for $\(cost)."
    }

    @discardableResult
    func sellStock(_ stock: Stock, shares: Int) -> String {
        guard var current = character, shares > 0, (current.stockHoldings[stock.id] ?? 0) >= shares else {
            return "You don't own that many shares."
        }
        let price = stockPrice(for: stock, character: current)
        let proceeds = max(0, Int((price * Double(shares)).rounded(.down)))
        current.stockHoldings[stock.id, default: 0] -= shares
        if current.stockHoldings[stock.id] == 0 { current.stockHoldings[stock.id] = nil }
        current.cash += proceeds
        character = current
        SoundManager.shared.play(.cash)
        return "Sold \(shares) share\(shares == 1 ? "" : "s") of \(stock.symbol) for $\(proceeds)."
    }

    /// A real heads/tails outcome (not just an abstract win-chance roll) so
    /// the coin art can show the side that actually landed. Cash and stats
    /// are settled immediately, but the win/lose chime is deliberately left
    /// to the caller — the coin takes a moment to visually flip, and the
    /// sound shouldn't give the result away before it lands.
    @discardableResult
    func flipCoin(_ amount: Int, callHeads: Bool) -> (landedHeads: Bool, text: String) {
        guard var current = character, current.age >= 18, amount > 0, current.cash >= amount else {
            return (true, "You don't have $\(amount) to bet.")
        }
        current.cash -= amount
        let landedHeads = Bool.random()
        let won = landedHeads == callHeads
        let text: String
        if won {
            let payout = amount * 2
            current.cash += payout
            current.stats.adjust(happiness: Int.random(in: 4...10))
            text = "\(landedHeads ? "Heads" : "Tails")! You won $\(payout)."
        } else {
            current.stats.adjust(happiness: -Int.random(in: 3...8))
            text = "\(landedHeads ? "Heads" : "Tails") — you lost your $\(amount) bet."
        }
        character = current
        return (landedHeads, text)
    }

    /// Settles every active bet against one spin of the wheel. Bets are
    /// deducted up front as a single total; winnings from each covered bet
    /// are added back once the ball drops. As with `flipCoin`, the result
    /// chime is left to the caller so it lands with the wheel, not before it
    /// even starts spinning.
    @discardableResult
    func spinRoulette(_ bets: [RouletteBetKind: Int]) -> (result: Int, text: String) {
        let total = bets.values.reduce(0, +)
        guard var current = character, current.age >= 18, total > 0, current.cash >= total else {
            return (0, "You don't have $\(total) to cover that bet.")
        }
        current.cash -= total

        let result = Int.random(in: 0...36)
        var winnings = 0
        for (kind, amount) in bets where kind.wins(for: result) {
            winnings += amount + amount * kind.payoutMultiple
        }
        current.cash += winnings

        let color = result == 0 ? "green" : (RouletteNumbers.reds.contains(result) ? "red" : "black")
        let text: String
        if winnings > total {
            current.stats.adjust(happiness: Int.random(in: 4...10))
            text = "The ball landed on \(result) (\(color)). You won $\(winnings - total)!"
        } else if winnings > 0 {
            text = "The ball landed on \(result) (\(color)). You broke even."
        } else {
            current.stats.adjust(happiness: -Int.random(in: 3...8))
            text = "The ball landed on \(result) (\(color)). You lost your $\(total) bet."
        }
        character = current
        return (result, text)
    }

    /// Classic "will the next roll be higher or lower" dice game. The view
    /// owns the running roll between calls and passes the previous total in.
    /// Sound is left to the caller — see `flipCoin`.
    @discardableResult
    func rollHighOrLow(_ amount: Int, previousTotal: Int, guessHigher: Bool) -> (dice: (Int, Int), text: String) {
        guard var current = character, current.age >= 18, amount > 0, current.cash >= amount else {
            return ((1, 1), "You don't have $\(amount) to bet.")
        }
        current.cash -= amount
        let dice = (Int.random(in: 1...6), Int.random(in: 1...6))
        let newTotal = dice.0 + dice.1
        let text: String
        if newTotal == previousTotal {
            current.cash += amount
            text = "Rolled \(newTotal) — a push. Your $\(amount) bet was returned."
        } else if (newTotal > previousTotal) == guessHigher {
            let payout = amount * 2
            current.cash += payout
            current.stats.adjust(happiness: Int.random(in: 4...10))
            text = "Rolled \(newTotal). You called it right and won $\(payout)."
        } else {
            current.stats.adjust(happiness: -Int.random(in: 3...8))
            text = "Rolled \(newTotal). You called it wrong and lost your $\(amount) bet."
        }
        character = current
        return (dice, text)
    }

    /// Deducts a bet up front — used for the initial deal, a double down,
    /// or a split's matching second bet. The table pays out once the
    /// relevant hand is settled.
    @discardableResult
    func placeBlackjackBet(_ amount: Int) -> Bool {
        guard var current = character, current.age >= 18, amount > 0, current.cash >= amount else { return false }
        current.cash -= amount
        character = current
        SoundManager.shared.play(.tap)
        return true
    }

    @discardableResult
    func settleBlackjack(bet: Int, outcome: BlackjackOutcome) -> String {
        guard var current = character else { return "" }
        let text: String
        switch outcome {
        case .blackjack:
            let payout = bet + Int(Double(bet) * 1.5)
            current.cash += payout
            current.stats.adjust(happiness: Int.random(in: 6...12))
            text = "Blackjack! You won $\(payout - bet) on your $\(bet) bet."
            SoundManager.shared.play(.achievement)
        case .win:
            current.cash += bet * 2
            current.stats.adjust(happiness: Int.random(in: 4...10))
            text = "You won $\(bet) at blackjack."
            SoundManager.shared.play(.success)
        case .push:
            current.cash += bet
            text = "Push — your $\(bet) bet was returned."
            SoundManager.shared.play(.tap)
        case .lose:
            current.stats.adjust(happiness: -Int.random(in: 3...8))
            text = "You lost your $\(bet) bet at blackjack."
            SoundManager.shared.play(.rejected)
        }
        character = current
        return text
    }

    func purchase(_ accessory: Accessory) {
        guard var current = character,
              current.cash >= accessory.price,
              !current.ownedAccessoryIDs.contains(accessory.id) else { return }
        current.cash -= accessory.price
        current.ownedAccessoryIDs.insert(accessory.id)
        current.equippedAccessoryIDs[accessory.slot] = accessory.id
        character = current
        SoundManager.shared.play(.cash)
    }

    func equip(_ accessory: Accessory) {
        guard var current = character, current.ownedAccessoryIDs.contains(accessory.id) else { return }
        current.equippedAccessoryIDs[accessory.slot] = accessory.id
        character = current
        SoundManager.shared.play(.tap)
    }

    func unequip(slot: AccessorySlot) {
        guard var current = character else { return }
        current.equippedAccessoryIDs[slot] = nil
        character = current
    }

    func purchaseOutfit(_ outfit: Outfit) {
        guard var current = character,
              current.cash >= outfit.price,
              !current.ownedOutfitIDs.contains(outfit.id) else { return }
        current.cash -= outfit.price
        current.ownedOutfitIDs.insert(outfit.id)
        current.equippedOutfitID = outfit.id
        character = current
        SoundManager.shared.play(.cash)
    }

    func equipOutfit(_ outfit: Outfit) {
        guard var current = character, current.ownedOutfitIDs.contains(outfit.id) else { return }
        current.equippedOutfitID = outfit.id
        character = current
        SoundManager.shared.play(.tap)
    }

    /// `nil` means the action is allowed; otherwise this is the message to
    /// show instead of performing it. Centralizes the shared yearly budget
    /// that keeps every interaction from being spammed for free.
    private func budgetMessage(_ character: Character, ref: PersonRef) -> String? {
        guard let history = relationshipHistory(character, ref: ref) else { return nil }
        guard history.remainingThisYear > 0 else {
            return personName(character, ref: ref).map { "\($0) needs a break from you — try again next year." } ?? "They need a break — try again next year."
        }
        return nil
    }

    @discardableResult
    func spendTime(with ref: PersonRef) -> String {
        guard var current = character else { return "" }
        if let blocked = budgetMessage(current, ref: ref) { return blocked }
        let history = relationshipHistory(current, ref: ref)
        let multiplier = (history?.diminishingMultiplier(for: "spendTime") ?? 1.0) * (history?.moodMultiplier(positive: true) ?? 1.0)
        let gain = max(1, Int(Double(Int.random(in: 4...10)) * multiplier))
        adjustRelationship(&current, ref: ref, by: gain)
        current.stats.adjust(happiness: 2)
        updateHistory(&current, ref: ref) { history in
            history.recordUse("spendTime")
            history.addResentment(-2)
        }
        character = current
        SoundManager.shared.play(.friendJoin)
        let moodNote = history?.isInGreatMood == true ? " They were in a great mood." : (history?.isInBadMood == true ? " They seemed a bit distant today." : "")
        return "You spent quality time together. Relationship +\(gain).\(moodNote)"
    }

    @discardableResult
    func giveGift(with ref: PersonRef, cost: Int = 15) -> String {
        guard var current = character else { return "" }
        if let blocked = budgetMessage(current, ref: ref) { return blocked }
        let localCost = localized(cost, for: current)
        guard current.cash >= localCost else { return "You don't have enough cash for a gift." }
        current.cash -= localCost
        let history = relationshipHistory(current, ref: ref)
        let multiplier = (history?.diminishingMultiplier(for: "gift") ?? 1.0) * (history?.moodMultiplier(positive: true) ?? 1.0)
        let gain = max(1, Int(Double(Int.random(in: 12...20)) * multiplier))
        adjustRelationship(&current, ref: ref, by: gain)
        updateHistory(&current, ref: ref) { history in
            history.recordUse("gift")
            history.addResentment(-3)
        }
        character = current
        SoundManager.shared.play(.success)
        return "You gave a $\(localCost) gift. Relationship +\(gain)."
    }

    @discardableResult
    func askForMoney(from ref: PersonRef) -> String {
        guard var current = character else { return "" }
        if let blocked = budgetMessage(current, ref: ref) { return blocked }
        let relationship = relationshipValue(current, ref: ref)
        let history = relationshipHistory(current, ref: ref) ?? RelationshipHistory()
        let name = personName(current, ref: ref) ?? "They"

        // Resentment and mood turn a simple ask into real risk — the more
        // you've leaned on someone, the more likely this blows up.
        let askCount = history.uses(of: "askMoney")
        let moodPenalty = history.isInBadMood ? 18 : (history.isInGreatMood ? -10 : 0)
        let badOutcomeChance = min(0.85, Double(max(0, 40 - relationship + history.resentment + askCount * 15 + moodPenalty)) / 100.0)

        updateHistory(&current, ref: ref) { $0.recordUse("askMoney") }

        if Double.random(in: 0...1) >= badOutcomeChance, relationship >= 40 {
            let multiplier = history.moodMultiplier(positive: true)
            let amount = localized(Int(Double(Int.random(in: 5...25)) * multiplier), for: current)
            current.cash += amount
            updateHistory(&current, ref: ref) { $0.addResentment(4) }
            character = current
            SoundManager.shared.play(.cash)
            return "\(name) happily gave you $\(amount)."
        }

        // Something goes wrong — graded by how badly this has been abused.
        let severity = Double.random(in: 0...1)
        if severity < 0.15, history.resentment > 40 || askCount >= 2 {
            let injuryName = inflictViolentInjury(&current, allowGunshot: false)
            adjustRelationship(&current, ref: ref, by: -Int.random(in: 20...35))
            updateHistory(&current, ref: ref) { $0.addResentment(15) }
            character = current
            SoundManager.shared.playSequence([.ouch, .alert])
            return "\(name) snapped at being asked again and came at you. You came away with \(injuryName.lowercased())."
        } else if severity < 0.5 {
            adjustRelationship(&current, ref: ref, by: -Int.random(in: 10...20))
            updateHistory(&current, ref: ref) { $0.addResentment(10) }
            character = current
            SoundManager.shared.play(.alert)
            return "\(name) accused you of only using them for money. That stung — and it cost you the relationship."
        } else {
            character = current
            SoundManager.shared.play(.tap)
            return "\(name) said no — you're not close enough yet."
        }
    }

    @discardableResult
    func prank(_ ref: PersonRef) -> String {
        guard var current = character else { return "" }
        if let blocked = budgetMessage(current, ref: ref) { return blocked }
        let history = relationshipHistory(current, ref: ref)
        let successChance = 0.5 * (history?.moodMultiplier(positive: true) ?? 1.0)
        updateHistory(&current, ref: ref) { $0.recordUse("prank") }
        if Double.random(in: 0...1) < successChance {
            let multiplier = history?.diminishingMultiplier(for: "prank") ?? 1.0
            let gain = max(1, Int(Double(Int.random(in: 2...8)) * multiplier))
            adjustRelationship(&current, ref: ref, by: gain)
            current.stats.adjust(happiness: 5)
            character = current
            SoundManager.shared.play(.success)
            return "Your prank landed perfectly! Everyone had a good laugh. Relationship +\(gain)."
        } else {
            let loss = Int.random(in: 5...12)
            adjustRelationship(&current, ref: ref, by: -loss)
            updateHistory(&current, ref: ref) { $0.addResentment(5) }
            character = current
            SoundManager.shared.play(.rejected)
            return "Your prank backfired badly. Relationship -\(loss)."
        }
    }

    @discardableResult
    func argue(with ref: PersonRef) -> String {
        guard var current = character else { return "" }
        if let blocked = budgetMessage(current, ref: ref) { return blocked }
        let history = relationshipHistory(current, ref: ref)
        let multiplier = history?.moodMultiplier(positive: false) ?? 1.0
        let loss = max(1, Int(Double(Int.random(in: 15...25)) * multiplier))
        adjustRelationship(&current, ref: ref, by: -loss)
        current.stats.adjust(happiness: -Int.random(in: 2...6))
        updateHistory(&current, ref: ref) {
            $0.recordUse("argue")
            $0.addResentment(8)
        }
        character = current
        SoundManager.shared.play(.alert)
        return "You got into a heated argument. Relationship -\(loss)."
    }

    @discardableResult
    func steal(from ref: PersonRef) -> String {
        guard var current = character else { return "" }
        if let blocked = budgetMessage(current, ref: ref) { return blocked }
        let history = relationshipHistory(current, ref: ref)
        let priorSteals = history?.uses(of: "steal") ?? 0
        let catchChance = min(0.85, 0.4 + Double(priorSteals) * 0.2 + Double(history?.resentment ?? 0) / 300.0)
        updateHistory(&current, ref: ref) { $0.recordUse("steal") }

        if Double.random(in: 0...1) < catchChance {
            let loss = Int.random(in: 25...40)
            adjustRelationship(&current, ref: ref, by: -loss)
            current.stats.adjust(happiness: -Int.random(in: 5...15))
            updateHistory(&current, ref: ref) { $0.addResentment(20) }
            if Double.random(in: 0...1) < 0.15, current.scars < 3 {
                current.scars += 1
            }
            character = current
            SoundManager.shared.play(.alert)
            return "You got caught red-handed! They're furious with you. Relationship -\(loss)."
        } else {
            let amount = localized(Int.random(in: 5...30), for: current)
            current.cash += amount
            let loss = Int.random(in: 5...10)
            adjustRelationship(&current, ref: ref, by: -loss)
            updateHistory(&current, ref: ref) { $0.addResentment(8) }
            character = current
            SoundManager.shared.play(.success)
            return "You secretly took $\(amount) without getting caught, but you feel a little guilty."
        }
    }

    @discardableResult
    func purchaseWeapon(_ weapon: Weapon) -> String {
        guard var current = character else { return "" }
        guard current.age >= 13 else { return "You are too young to buy a weapon." }
        guard current.weaponName == nil else { return "You already have a \(current.weaponName!). Sell it first." }
        let cost = localized(weapon.price, for: current)
        guard current.cash >= cost else { return "You need $\(cost) to buy this." }

        current.cash -= cost
        current.weaponName = weapon.name
        character = current
        SoundManager.shared.play(weapon.isIllegal ? .danger : .cash)
        return weapon.isIllegal
            ? "You bought a \(weapon.name) off the books for $\(cost). If the police ever search you, that's a charge."
            : "You bought a \(weapon.name) for $\(cost)."
    }

    @discardableResult
    func sellWeapon() -> String {
        guard var current = character, let name = current.weaponName else { return "" }
        let weapon = WeaponData.all.first { $0.name == name }
        let refund = localized(weapon?.sellValue ?? 0, for: current)
        current.cash += refund
        current.weaponName = nil
        character = current
        SoundManager.shared.play(.cash)
        return "You sold your \(name) for $\(refund)."
    }

    @discardableResult
    func joinGang() -> String {
        guard var current = character else { return "" }
        guard current.age >= 13 else { return "You are too young to join a gang." }
        guard current.gangName == nil else { return "You are already with \(current.gangName!)." }

        let gangNames = ["Northside Crew", "Red Lane Mob", "Glass Street", "The Yard", "Kingfisher Set"]
        let chance = 0.30 + Double(100 - current.stats.smarts) / 450.0 + Double(current.stats.looks) / 700.0
        if Double.random(in: 0...1) < chance {
            let name = gangNames.randomElement()!
            current.gangName = name
            current.policeHeat += 8
            current.stats.adjust(happiness: Int.random(in: 2...8), smarts: -Int.random(in: 0...2))
            SoundManager.shared.play(.danger)
            return commitCrimeResult(current, text: "You joined \(name). People treat you differently now, and the police have started to notice.", isAlert: true)
        }

        let injuryName = inflictViolentInjury(&current, allowGunshot: false)
        current.stats.adjust(happiness: -Int.random(in: 2...7))
        SoundManager.shared.play(.ouch)
        return commitCrimeResult(current, text: "You tried to join a gang and got beaten up instead, leaving you with \(injuryName.lowercased()).", isAlert: true)
    }

    @discardableResult
    func leaveGang() -> String {
        guard var current = character else { return "" }
        guard let gangName = current.gangName else { return "You are not in a gang." }

        if Double.random(in: 0...1) < 0.55 {
            current.gangName = nil
            current.stats.adjust(happiness: 4)
            SoundManager.shared.play(.success)
            return commitCrimeResult(current, text: "You walked away from \(gangName). It may not stay quiet forever.", isAlert: true)
        }

        let injuryName = inflictViolentInjury(&current, allowGunshot: false)
        current.stats.adjust(happiness: -Int.random(in: 2...8))
        SoundManager.shared.play(.ouch)
        return commitCrimeResult(current, text: "\(gangName) did not let you leave cleanly, leaving you with \(injuryName.lowercased()).", isAlert: true)
    }

    func robberyEligibilityMessage() -> String? {
        guard let current = character else { return "Start a life before attempting a robbery." }
        guard current.age >= 13 else { return "You must be at least 13 to attempt a robbery." }
        return nil
    }

    /// Rolled once right before the mini-game launches: a small chance the
    /// mark is connected, and a randomized difficulty so no two robberies
    /// play quite the same.
    func prepareRobbery() -> RobberySetup {
        RobberySetup(isMafiaBoss: Double.random(in: 0...1) < 0.08, difficulty: .random(), scenario: .random())
    }

    @discardableResult
    func resolveMafiaRobberyCaught() -> String {
        guard var current = character else { return "" }
        current.isAlive = false
        current.causeOfDeath = "a mafia boss's bodyguards, after a robbery gone very wrong"
        character = current

        let text = "Turns out the person you tried to rob was a mafia boss. The moment his bodyguards spotted you, they didn't call the police — they opened fire."
        var log = yearLog
        log.append(LogEntry(text: text, isAlert: true))
        yearLog = log
        isGameOver = true
        attackTrigger += 1
        SoundManager.shared.playSequence([.alert, .death])
        return text
    }

    @discardableResult
    func resolveRobberyMiniGame(success: Bool, lootValue: Int? = nil, scenario: RobberyScenario = .pickpocket) -> String {
        guard var current = character else { return "" }
        guard current.age >= 13 else { return "You must be at least 13 to attempt a robbery." }

        current.robberyCount += 1
        let crime: CrimeType = scenario == .houseBurglary ? .burglary : .pickpocketing
        let masked = current.isMasked
        var summary: String
        var injured = false

        if success {
            let amount = lootValue.map { localized($0, for: current) } ?? localized(Int.random(in: 35...380), for: current)
            current.cash += amount
            current.policeHeat += scenario == .houseBurglary ? 10 : 6
            current.stats.adjust(happiness: -Int.random(in: 1...6), smarts: 1)
            summary = scenario == .houseBurglary
                ? "You slipped out of the house with jewelry and cash worth $\(amount)."
                : "You lifted a wallet without being noticed and escaped with $\(amount)."
        } else {
            let fine = min(current.cash, localized(Int.random(in: 30...240), for: current))
            current.cash -= fine
            current.policeHeat += 10
            let injuryName = inflictViolentInjury(&current, allowGunshot: false)
            current.stats.adjust(happiness: -Int.random(in: 5...12))
            injured = true
            summary = scenario == .houseBurglary
                ? "The homeowner came back and caught you inside. You lost $\(fine) in the scuffle and came away with \(injuryName.lowercased())."
                : "You were spotted and they fought back. You lost $\(fine) and came away with \(injuryName.lowercased())."
        }

        // Getting spotted makes an arrest far more likely, but even a clean
        // job can draw a squad car if you've been pushing your luck.
        let chance = arrestChance(current, base: success ? 0.04 + Double(current.robberyCount) * 0.01 : 0.4, masked: masked)
        if Double.random(in: 0...1) < chance {
            summary += " Moments later, a police squad caught up with you and placed you under arrest."
            arrest(&current, for: crime, caughtAtScene: !success, story: success ? "A patrol car picked you up a few streets away." : "The police arrived before you could get away.")
            SoundManager.shared.playSequence(injured ? [.ouch, .alert] : [.alert])
            return commitCrimeResult(current, text: summary, isAlert: true)
        }

        if !success {
            summary += " You got away before the police showed up."
        }
        if masked {
            summary += " Your balaclava kept your face hidden."
        }
        openCaseMaybe(&current, crime: crime, chance: success ? 0.25 : 0.6, masked: masked)
        SoundManager.shared.playSequence(injured ? [.ouch, .alert] : [.success])
        return commitCrimeResult(current, text: summary, isAlert: true)
    }

    @discardableResult
    func shoplift() -> String {
        guard var current = character else { return "" }
        guard current.age >= 10 else { return "You're too young to shoplift." }
        let masked = current.isMasked

        // Walking into a shop in a balaclava gets you watched the whole time.
        let successChance = (masked ? 0.35 : 0.72) + Double(current.stats.smarts) / 1000.0
        if Double.random(in: 0...1) < successChance {
            let loot = localized(Int.random(in: 15...160), for: current)
            current.cash += loot
            current.policeHeat += 3
            current.stats.adjust(happiness: Int.random(in: 0...3))
            openCaseMaybe(&current, crime: .shoplifting, chance: 0.12, masked: false)
            SoundManager.shared.play(.success)
            return commitCrimeResult(current, text: "You slipped some stuff into your bag and walked out. It sold for $\(loot).", isAlert: false)
        }

        current.policeHeat += 5
        let maskNote = masked ? " Wearing a balaclava into a shop was not subtle." : ""
        if Double.random(in: 0...1) < 0.6 {
            arrest(&current, for: .shoplifting, caughtAtScene: true, story: "Store security held you until the police arrived.")
            SoundManager.shared.play(.alert)
            return commitCrimeResult(current, text: "Store security grabbed you at the door and called the police.\(maskNote)", isAlert: true)
        }
        current.stats.adjust(happiness: -Int.random(in: 2...5))
        SoundManager.shared.play(.rejected)
        return commitCrimeResult(current, text: "Security caught you, took the stuff back and banned you from the store. No police this time.\(maskNote)", isAlert: true)
    }

    @discardableResult
    func stealCar() -> String {
        guard var current = character else { return "" }
        guard current.age >= 16 else { return "You must be at least 16 to steal a car." }
        let masked = current.isMasked

        let toolBonus = ["crowbar", "sledgehammer"].contains(current.weapon?.id ?? "") ? 0.1 : 0
        let successChance = min(0.85, 0.42 + Double(current.stats.smarts) / 350.0 + toolBonus)
        if Double.random(in: 0...1) < successChance {
            let value = localized(Int.random(in: 1_500...12_000), for: current)
            current.cash += value
            current.policeHeat += 12
            current.stats.adjust(happiness: Int.random(in: 2...6))
            if Double.random(in: 0...1) < arrestChance(current, base: 0.06, masked: masked) {
                arrest(&current, for: .carTheft, caughtAtScene: false, story: "A traffic camera caught the plates and the police tracked you down.")
                SoundManager.shared.playSequence([.cash, .alert])
                return commitCrimeResult(current, text: "You sold the car to a chop shop for $\(value), but a traffic camera caught the plates. The police tracked you down.", isAlert: true)
            }
            openCaseMaybe(&current, crime: .carTheft, chance: 0.35, masked: masked)
            SoundManager.shared.play(.cash)
            return commitCrimeResult(current, text: "You hot-wired a car and sold it to a chop shop for $\(value).", isAlert: true)
        }

        current.policeHeat += 8
        if Double.random(in: 0...1) < arrestChance(current, base: 0.45, masked: masked) {
            arrest(&current, for: .carTheft, caughtAtScene: true, story: "The car alarm went off and a patrol car was right around the corner.")
            SoundManager.shared.play(.alert)
            return commitCrimeResult(current, text: "The car alarm screamed and a patrol car pulled up before you got the door open. You were arrested.", isAlert: true)
        }
        SoundManager.shared.play(.rejected)
        return commitCrimeResult(current, text: "The car alarm went off and you ran. Nobody followed you, this time.", isAlert: true)
    }

    @discardableResult
    func armedRobbery() -> String {
        guard var current = character else { return "" }
        guard current.age >= 16 else { return "You must be at least 16 for an armed robbery." }
        guard let weapon = current.weapon else { return "You need a weapon to hold up a store. Visit the Weapons shop." }
        let masked = current.isMasked

        let successChance = min(0.9, 0.3 + Double(weapon.power) * 0.05 + Double(current.stats.smarts) / 600.0 + (current.gangName == nil ? 0 : 0.06))
        if Double.random(in: 0...1) < successChance {
            let take = Int(Double(localized(Int.random(in: 300...2_500), for: current)) * (1 + Double(weapon.power) / 10))
            current.cash += take
            current.policeHeat += 20
            current.stats.adjust(happiness: -Int.random(in: 0...4))
            if Double.random(in: 0...1) < arrestChance(current, base: 0.12, masked: masked) {
                arrest(&current, for: .armedRobbery, caughtAtScene: false, story: "Security footage led the police straight to you.")
                SoundManager.shared.playSequence([.cash, .alert])
                return commitCrimeResult(current, text: "You held up a store with your \(weapon.name) and got away with $\(take), but the cameras got a good look at you. Police picked you up that night.", isAlert: true)
            }
            openCaseMaybe(&current, crime: .armedRobbery, chance: 0.5, masked: masked)
            SoundManager.shared.play(.cash)
            let maskNote = masked ? " The balaclava kept your face off the cameras." : ""
            return commitCrimeResult(current, text: "You held up a store with your \(weapon.name) and walked out with $\(take).\(maskNote)", isAlert: true)
        }

        current.policeHeat += 15
        let injuryName = inflictViolentInjury(&current, allowGunshot: Double.random(in: 0...1) < 0.35)
        current.stats.adjust(happiness: -Int.random(in: 6...12))
        attackTrigger += 1
        if Double.random(in: 0...1) < arrestChance(current, base: 0.55, masked: masked) {
            arrest(&current, for: .armedRobbery, caughtAtScene: true, story: "The clerk hit the panic button and police swarmed the store.")
            SoundManager.shared.playSequence([.ouch, .alert])
            return commitCrimeResult(current, text: "The clerk fought back, leaving you with \(injuryName.lowercased()), and hit the panic button. Police swarmed the store.", isAlert: true)
        }
        SoundManager.shared.playSequence([.ouch, .alert])
        return commitCrimeResult(current, text: "The clerk fought back and you fled empty handed with \(injuryName.lowercased()).", isAlert: true)
    }

    @discardableResult
    func layLow() -> String {
        guard var current = character else { return "" }
        guard current.policeHeat > 0 else { return "The police aren't looking for you. No need to hide." }
        let cost = localized(400, for: current)
        guard current.cash >= cost else { return "You need $\(cost) to lie low for a while." }
        current.cash -= cost
        current.policeHeat -= 25
        current.stats.adjust(happiness: -Int.random(in: 1...4))
        SoundManager.shared.play(.tap)
        return commitCrimeResult(current, text: "You spent $\(cost) hiding out and staying off the streets. The police have cooled off a bit.", isAlert: false)
    }

    // MARK: - Police and court

    private func arrestChance(_ character: Character, base: Double, masked: Bool) -> Double {
        var chance = base + Double(character.policeHeat) / 250.0 + (character.isFugitive ? 0.15 : 0)
        if masked { chance *= 0.6 }
        if character.hasGetawayVehicle { chance *= 0.9 }
        return min(0.92, max(0.01, chance))
    }

    /// A crime you got away with might still be on the police's desk. Each
    /// year it could lead back to you, until it goes cold.
    private func openCaseMaybe(_ character: inout Character, crime: CrimeType, chance: Double, masked: Bool) {
        let finalChance = masked ? chance * 0.6 : chance
        guard Double.random(in: 0...1) < finalChance else { return }
        if let index = character.openCases.firstIndex(where: { $0.crime == crime }) {
            character.openCases[index].yearsOpen = 0
        } else {
            character.openCases.append(OpenCase(crime: crime))
        }
    }

    /// Puts the character in handcuffs: searches them, seizes weapons and
    /// opens the court case that the legal sheet walks through.
    private func arrest(_ character: inout Character, for crime: CrimeType, caughtAtScene: Bool, story: String) {
        var charges = [crime]
        var seized: String?
        if let weapon = character.weapon {
            let violent: Set<CrimeType> = [.armedRobbery, .bankRobbery, .assault, .attemptedMurder, .murder]
            if weapon.isIllegal {
                if crime != .weaponPossession && crime != .weaponSmuggling {
                    charges.append(.weaponPossession)
                }
                seized = weapon.name
                character.weaponName = nil
            } else if violent.contains(crime) {
                seized = weapon.name
                character.weaponName = nil
            }
        }
        character.openCases.removeAll { $0.crime == crime }
        character.policeHeat += 10

        let maskable = !caughtAtScene && character.isMasked
        var evidence = crime.baseEvidence
            + (caughtAtScene ? 0.25 : 0)
            + Double(character.policeHeat) / 400.0
            - (maskable ? 0.15 : 0)
            + Double.random(in: -0.1...0.1)
        evidence = min(0.95, max(0.15, evidence))

        let lead = charges.max { $0.severity < $1.severity } ?? crime
        let bail = localized(Int.random(in: lead.severity.bailRange), for: character)
        let privateLawyer = localized(Int.random(in: lead.severity.privateLawyerRange), for: character)
        pendingLegalTrouble = LegalTrouble(
            charges: charges,
            evidence: evidence,
            bailAmount: bail,
            bondsmanFee: bail == 0 ? 0 : max(1, bail * 15 / 100),
            privateLawyerCost: privateLawyer,
            topAttorneyCost: Int(Double(privateLawyer) * lead.severity.topAttorneyMultiplier),
            seizedWeapon: seized,
            arrestStory: story
        )
    }

    func lawyerCost(_ lawyer: LawyerOption, for trouble: LegalTrouble) -> Int {
        switch lawyer {
        case .selfRepresented, .publicDefender: return 0
        case .privateLawyer: return trouble.privateLawyerCost
        case .topAttorney: return trouble.topAttorneyCost
        }
    }

    /// Chance of a guilty verdict if you plead not guilty and go to trial.
    func trialConvictionChance(_ lawyer: LawyerOption, for trouble: LegalTrouble) -> Double {
        let record = Double(character?.criminalRecord ?? 0)
        // People who practice law do a lot better defending themselves.
        let isLawyer = character?.activeCareer?.trackID == "law"
        let weight = lawyer == .selfRepresented && isLawyer ? 0.6 : lawyer.evidenceWeight
        var chance = trouble.evidence * weight + record * 0.015
        if lawyer == .publicDefender { chance += 0.08 }
        if lawyer == .selfRepresented { chance -= Double(character?.stats.smarts ?? 50) / 1000.0 }
        if character?.isFugitive == true { chance += 0.1 }
        return min(0.97, max(0.03, chance))
    }

    /// Rolled once when the case reaches the courtroom. Better lawyers read
    /// the case right; a public defender sometimes gets it badly wrong.
    func lawyerAdvice(_ lawyer: LawyerOption, for trouble: LegalTrouble) -> LawyerAdvice? {
        guard lawyer != .selfRepresented else { return nil }
        let smartCallIsGuilty = trialConvictionChance(lawyer, for: trouble) > 0.6
        let readsItRight = Double.random(in: 0...1) < lawyer.adviceAccuracy
        let recommendsGuilty = readsItRight ? smartCallIsGuilty : !smartCallIsGuilty

        let line: String
        switch (lawyer, recommendsGuilty) {
        case (.publicDefender, true):
            line = "Uh, I skimmed your file on the way in. Looks bad? I'd just plead guilty and get it over with."
        case (.publicDefender, false):
            line = "I haven't really had time to read this... but plead not guilty, I guess? Let's see what happens."
        case (.topAttorney, true):
            line = "I'll be straight with you. Their evidence is airtight. Plead guilty and I'll get your sentence cut in half."
        case (.topAttorney, false):
            line = "Their case is full of holes and I know every one of them. Plead not guilty. Leave the rest to me."
        case (_, true):
            line = "The evidence is \(trouble.evidenceLabel.lowercased()). If we fight this we'll probably lose. My advice is to plead guilty for a lighter sentence."
        case (_, false):
            line = "The evidence is only \(trouble.evidenceLabel.lowercased()). I think we can win this. Plead not guilty."
        }
        return LawyerAdvice(recommendsGuilty: recommendsGuilty, line: line)
    }

    /// Runs the whole procedure in one go: the bail hearing, the lawyer's
    /// fee, the trial and the sentence. The legal sheet stays up to play
    /// the courtroom cutscene until `closeCourtCase()` is called, and the
    /// cutscene plays the verdict sounds when the jury reads it out.
    func resolveCourtCase(paidBail: Bool, lawyer chosenLawyer: LawyerOption, pleadGuilty: Bool) -> CourtVerdict {
        guard let trouble = pendingLegalTrouble, var current = character else {
            return CourtVerdict(guilty: false, years: 0, fine: 0, recordPoints: 0, headline: "", summary: "")
        }
        var notes: [String] = []

        // Bail hearing
        if !trouble.bailDenied, paidBail, current.cash >= trouble.bondsmanFee {
            current.cash -= trouble.bondsmanFee
            notes.append("You paid a bondsman $\(trouble.bondsmanFee) to get out on bail before trial.")
        } else {
            current.stats.adjust(happiness: -Int.random(in: 4...10))
            notes.append(trouble.bailDenied ? "Bail was denied, so you waited for trial in a cell." : "You stayed locked up until your trial.")
            if let job = current.job, Double.random(in: 0...1) < 0.5 {
                current.job = nil
                current.yearsAtJob = 0
                notes.append("You lost your job as \(job.title) while you were stuck inside.")
            }
        }

        // Paying the lawyer
        var lawyer = chosenLawyer
        let fee = lawyerCost(lawyer, for: trouble)
        if fee > current.cash {
            lawyer = .publicDefender
        } else {
            current.cash -= fee
        }
        let guilty = pleadGuilty || Double.random(in: 0...1) < trialConvictionChance(lawyer, for: trouble)

        let verdict: CourtVerdict
        if guilty {
            let lead = trouble.leadCharge
            var years = Int.random(in: lead.sentenceRange)
            for extra in trouble.charges where extra != lead {
                years += extra.sentenceRange.lowerBound
            }
            years = Int((Double(years) * (pleadGuilty ? 0.5 : lawyer.sentenceMultiplier)).rounded())
            let rawFine = trouble.charges.reduce(0) { $0 + localized(Int.random(in: $1.fineRange), for: current) }
            let fine = min(current.cash, pleadGuilty ? rawFine * 6 / 10 : rawFine)
            let points = trouble.charges.reduce(0) { $0 + $1.severity.recordPoints }

            current.cash -= fine
            current.criminalRecord += points
            current.convictions.append(contentsOf: trouble.charges.map(\.displayName))
            current.jailYearsRemaining += years
            current.policeHeat -= 30
            current.stats.adjust(happiness: -Int.random(in: years > 0 ? 12...22 : 6...12))

            if let job = current.job {
                if years > 0 {
                    current.job = nil
                    current.yearsAtJob = 0
                    notes.append("You lost your job as \(job.title).")
                } else if !JobData.passesBackgroundCheck(job, record: current.criminalRecord) {
                    current.job = nil
                    current.yearsAtJob = 0
                    notes.append("\(job.title) doesn't allow employees with a record. You were fired.")
                }
            }

            let howText = pleadGuilty ? "You pleaded guilty" : "The jury found you guilty"
            let timeText = years > 0 ? "sentenced to \(years) year\(years == 1 ? "" : "s") in prison" : "given probation"
            let fineText = fine > 0 ? " and fined $\(fine)" : ""
            let summary = "\(howText) of \(trouble.chargeDescription). You were \(timeText)\(fineText). This is now on your criminal record."
            verdict = CourtVerdict(guilty: true, years: years, fine: fine, recordPoints: points, headline: "Guilty", summary: summary)
        } else {
            current.policeHeat -= 15
            current.stats.adjust(happiness: Int.random(in: 4...10))
            let lawyerText: String
            switch lawyer {
            case .selfRepresented: lawyerText = "You argued your own case and the jury bought it."
            case .publicDefender: lawyerText = "Somehow your public defender pulled it off."
            case .privateLawyer: lawyerText = "Your lawyer picked the evidence apart."
            case .topAttorney: lawyerText = "Your attorney made the prosecution look foolish."
            }
            let summary = "Not guilty on \(trouble.chargeDescription). \(lawyerText) Your record stays clean of this one."
            verdict = CourtVerdict(guilty: false, years: 0, fine: 0, recordPoints: 0, headline: "Not Guilty", summary: summary)
        }

        if chosenLawyer != lawyer {
            notes.insert("You couldn't pay the lawyer, so a public defender took the case.", at: 0)
        } else if fee > 0 {
            notes.append("Legal fees came to $\(fee).")
        }

        let fullText = ([verdict.summary] + notes).joined(separator: " ")
        _ = commitCrimeResult(current, text: fullText, isAlert: true)
        return CourtVerdict(guilty: verdict.guilty, years: verdict.years, fine: verdict.fine, recordPoints: verdict.recordPoints, headline: verdict.headline, summary: fullText)
    }

    func closeCourtCase() {
        pendingLegalTrouble = nil
    }

    /// Yearly police work: heat cools off, old cases can catch up with you,
    /// and carrying an illegal weapon risks a stop and search.
    private func handlePolicing(_ character: inout Character, log: inout [LogEntry]) {
        character.policeHeat -= 12
        guard !character.isInJail, pendingSocialEvent == nil, pendingLegalTrouble == nil else { return }

        var cases = character.openCases
        for index in cases.indices {
            cases[index].yearsOpen += 1
        }
        let breakChance = 0.10 + Double(character.policeHeat) / 300.0
        let crackedIndex = cases.indices.shuffled().first { _ in Double.random(in: 0...1) < breakChance }
        var cracked: OpenCase?
        if let crackedIndex {
            cracked = cases.remove(at: crackedIndex)
        }
        let cold = cases.filter { !$0.crime.neverGoesCold && $0.yearsOpen >= 5 }
        cases.removeAll { !$0.crime.neverGoesCold && $0.yearsOpen >= 5 }
        character.openCases = cases
        for item in cold {
            log.append(LogEntry(text: "The police investigation into a \(item.crime.displayName.lowercased()) case went cold. \(character.firstName) is in the clear.", isAlert: false))
        }

        if let cracked {
            let story = "Detectives reopened an old \(cracked.crime.displayName.lowercased()) case and it led to you."
            arrest(&character, for: cracked.crime, caughtAtScene: false, story: story)
            log.append(LogEntry(text: "Police knocked on \(character.firstName)'s door. \(story)", isAlert: true))
            return
        }

        if let weapon = character.weapon, weapon.isIllegal,
           Double.random(in: 0...1) < 0.05 + Double(character.policeHeat) / 300.0 {
            let story = "Police stopped and searched you on the street and found your \(weapon.name)."
            arrest(&character, for: .weaponPossession, caughtAtScene: true, story: story)
            log.append(LogEntry(text: "\(character.firstName) was stopped and searched. Police found the \(weapon.name).", isAlert: true))
        }
    }

    /// The yearly track while serving a sentence — no career, no shopping,
    /// no social life, just prison life until release (or an escape).
    private func handleJailYear(_ character: inout Character, log: inout [LogEntry]) {
        character.jailYearsRemaining -= 1
        let name = character.firstName

        let roll = Double.random(in: 0...1)
        switch roll {
        case ..<0.16:
            let injuryName = inflictViolentInjury(&character, allowGunshot: false)
            character.stats.adjust(happiness: -Int.random(in: 4...10))
            log.append(LogEntry(text: "\(name) got caught up in a fight in the yard, coming away with \(injuryName.lowercased()).", isAlert: true))
            SoundManager.shared.playSequence([.ouch, .alert])
        case ..<0.30:
            character.stats.adjust(happiness: -Int.random(in: 6...14))
            log.append(LogEntry(text: "\(name) spent time in solitary confinement after a write-up.", isAlert: true))
            SoundManager.shared.play(.sad)
        case ..<0.45:
            character.stats.adjust(happiness: -Int.random(in: 3...8))
            log.append(LogEntry(text: "\(name) got caught with contraband and lost their good behavior credit.", isAlert: true))
            SoundManager.shared.play(.alert)
        case ..<0.60:
            character.stats.adjust(happiness: Int.random(in: 2...6), smarts: Int.random(in: 1...4))
            log.append(LogEntry(text: "\(name) joined a prison education program to pass the time.", isAlert: false))
            SoundManager.shared.play(.tap)
        case ..<0.72:
            character.stats.adjust(happiness: Int.random(in: 2...6))
            log.append(LogEntry(text: "\(name) made an ally inside who watches their back.", isAlert: false))
            SoundManager.shared.play(.friendJoin)
        case ..<0.80 where character.jailYearsRemaining > 0:
            character.jailYearsRemaining = max(0, character.jailYearsRemaining - 1)
            log.append(LogEntry(text: "\(name) was granted time off their sentence for good behavior.", isAlert: false))
            SoundManager.shared.play(.success)
        default:
            character.stats.adjust(happiness: -Int.random(in: 2...6))
            log.append(LogEntry(text: "\(name) served another long, uneventful year behind bars.", isAlert: false))
            SoundManager.shared.play(.tap)
        }

        if character.jailYearsRemaining <= 0 {
            character.jailYearsRemaining = 0
            log.append(LogEntry(text: "\(name) was released from prison.", isAlert: false))
        }
    }

    var canAttemptEscape: Bool { character?.isInJail == true }

    /// A real risk/reward option: succeed and you're free immediately as a
    /// fugitive; fail and the consequences (more years, injuries, even
    /// death) can be worse than just serving the original sentence.
    @discardableResult
    func attemptEscape() -> String {
        guard var current = character, current.isInJail else { return "" }

        let chance = min(0.6, 0.18 + Double(current.stats.smarts) / 300.0)
        if Double.random(in: 0...1) < chance {
            current.jailYearsRemaining = 0
            current.isFugitive = true
            current.policeHeat = 100
            character = current
            SoundManager.shared.play(.achievement)
            var log = yearLog
            log.append(LogEntry(text: "\(current.firstName) slipped past the guards and escaped. There's no undoing this — they're a fugitive now.", isAlert: true))
            yearLog = log
            return "You escaped! You're free, but you're a fugitive for life."
        }

        let deathRoll = Double.random(in: 0...1)
        if deathRoll < 0.08 {
            current.isAlive = false
            current.causeOfDeath = "a guard's gunshot during a failed prison escape"
            character = current
            attackTrigger += 1
            SoundManager.shared.playSequence([.alert, .death])
            var log = yearLog
            log.append(LogEntry(text: "\(current.firstName) was shot by a guard during a failed escape attempt.", isAlert: true))
            yearLog = log
            isGameOver = true
            return "Your escape attempt ended in gunfire. You didn't make it."
        }

        let extraYears = Int.random(in: 2...5)
        current.jailYearsRemaining += extraYears
        let injuryName = inflictViolentInjury(&current, allowGunshot: false)
        current.stats.adjust(happiness: -Int.random(in: 10...20))
        character = current
        SoundManager.shared.playSequence([.ouch, .alert])
        var log = yearLog
        log.append(LogEntry(text: "\(current.firstName)'s escape attempt failed. Guards caught them, leaving them with \(injuryName.lowercased()) and \(extraYears) more years added to their sentence.", isAlert: true))
        yearLog = log
        return "The escape failed. \(extraYears) years were added to your sentence."
    }

    @discardableResult
    func attemptMurder() -> String {
        guard var current = character else { return "" }
        guard current.age >= 16 else { return "You are too young for this." }
        guard let target = randomCrimeTarget(from: current) else { return "There is nobody close enough to target." }

        let masked = current.isMasked
        let weaponPower = Double(current.weapon?.power ?? 0)
        let chance = 0.10
            + Double(current.stats.smarts) / 650.0
            + weaponPower * 0.03
            + (current.gangName == nil ? 0 : 0.10)
        if Double.random(in: 0...1) < chance {
            removeCrimeTarget(target.ref, from: &current)
            current.policeHeat += 40
            current.stats.adjust(happiness: -Int.random(in: 12...28), smarts: -Int.random(in: 1...4))
            SoundManager.shared.play(.death)
            if Double.random(in: 0...1) < arrestChance(current, base: 0.2, masked: masked) {
                arrest(&current, for: .murder, caughtAtScene: false, story: "Detectives linked you to \(target.name)'s death.")
                return commitCrimeResult(current, text: "\(target.name) died after your attack. Within days, detectives were at your door.", isAlert: true)
            }
            // Murder cases never close on their own.
            openCaseMaybe(&current, crime: .murder, chance: 1, masked: false)
            return commitCrimeResult(current, text: "\(target.name) died after your attack. Your life feels darker now, and the police have opened a murder investigation.", isAlert: true)
        }

        let fine = min(current.cash, localized(Int.random(in: 90...600), for: current))
        current.cash -= fine
        current.policeHeat += 25
        let injuryName = inflictViolentInjury(&current, allowGunshot: true)
        current.stats.adjust(happiness: -Int.random(in: 8...18))
        if current.stats.health <= 0, Double.random(in: 0...1) < 0.22 {
            current.isAlive = false
            current.causeOfDeath = "a violent attack gone wrong"
            SoundManager.shared.playSequence([.ouch, .death])
            return commitCrimeResult(current, text: "Your attack on \(target.name) went horribly wrong. You died from your injuries.", isAlert: true)
        }
        SoundManager.shared.playSequence([.ouch, .alert])
        if Double.random(in: 0...1) < arrestChance(current, base: 0.5, masked: masked) {
            arrest(&current, for: .attemptedMurder, caughtAtScene: true, story: "\(target.name) survived and told the police everything.")
            return commitCrimeResult(current, text: "Your attack on \(target.name) failed and they fought back, leaving you with \(injuryName.lowercased()). They went straight to the police.", isAlert: true)
        }
        openCaseMaybe(&current, crime: .attemptedMurder, chance: 0.8, masked: masked)
        return commitCrimeResult(current, text: "Your attack on \(target.name) failed and they fought back. You lost $\(fine) and came away with \(injuryName.lowercased()).", isAlert: true)
    }

    @discardableResult
    func hireHitman() -> String {
        guard var current = character else { return "" }
        guard current.age >= 18 else { return "You must be an adult to hire a hitman." }
        guard let target = randomCrimeTarget(from: current) else { return "There is nobody close enough to target." }

        let cost = localized(900, for: current)
        guard current.cash >= cost else { return "You need $\(cost) to hire a hitman." }
        current.cash -= cost

        let roll = Double.random(in: 0...1)
        if roll < 0.34 {
            removeCrimeTarget(target.ref, from: &current)
            current.policeHeat += 20
            current.stats.adjust(happiness: -Int.random(in: 15...32), smarts: -Int.random(in: 2...5))
            SoundManager.shared.play(.death)
            openCaseMaybe(&current, crime: .murderForHire, chance: 0.5, masked: false)
            return commitCrimeResult(current, text: "The hitman killed \(target.name). You paid $\(cost), and the guilt is hard to shake.", isAlert: true)
        }
        if roll < 0.60 {
            current.stats.adjust(happiness: -Int.random(in: 8...18))
            SoundManager.shared.play(.alert)
            arrest(&current, for: .conspiracyToMurder, caughtAtScene: true, story: "The \"hitman\" was an undercover cop wearing a wire.")
            return commitCrimeResult(current, text: "The hitman was an undercover cop. The moment you handed over $\(cost), officers burst in and arrested you.", isAlert: true)
        }

        current.stats.adjust(happiness: -Int.random(in: 4...12))
        SoundManager.shared.play(.tap)
        return commitCrimeResult(current, text: "The hitman vanished with your $\(cost). Nothing happened except the dread.", isAlert: true)
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
        SoundManager.shared.play(diagnosed.isEmpty ? .tap : .diagnose)
        return CheckupOutcome(dialogue: opening, diagnosedConditions: diagnosed)
    }

    @discardableResult
    func treat(_ activeID: UUID) -> String {
        guard var current = character,
              let index = current.conditions.firstIndex(where: { $0.id == activeID }),
              current.conditions[index].isDiagnosed,
              let condition = ConditionData.byID[current.conditions[index].conditionID] else { return "" }
        guard !condition.requiresGlasses else { return "This isn't fixed by treatment — try a pair of glasses from the Shop." }
        let cost = condition.treatmentCost
        guard current.cash >= cost else { return "You can't afford treatment for this right now." }
        current.cash -= cost
        current.conditions.remove(at: index)
        current.stats.adjust(health: Int.random(in: 5...15))
        character = current
        SoundManager.shared.play(.treat)
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
            sum + (ConditionData.byID[current.conditions[index].conditionID]?.treatmentCost ?? 0)
        }
        guard current.cash >= totalCost else { return "You can't afford to treat everything ($\(totalCost))." }

        let treatedIDs = Set(treatableIndices.map { current.conditions[$0].id })
        let names = treatableIndices.compactMap { ConditionData.byID[current.conditions[$0].conditionID]?.name }
        current.cash -= totalCost
        current.conditions.removeAll { treatedIDs.contains($0.id) }
        current.stats.adjust(health: Int.random(in: 5...15))
        character = current
        SoundManager.shared.play(.treat)
        return "Treated: \(names.joined(separator: ", "))."
    }

    private func commitCrimeResult(_ current: Character, text: String, isAlert: Bool) -> String {
        var updated = current
        var log = yearLog
        log.append(LogEntry(text: text, isAlert: isAlert))
        checkForDeath(&updated, log: &log)
        character = updated
        yearLog = log
        if !updated.isAlive {
            isGameOver = true
        }
        return text
    }

    private func randomCrimeTarget(from character: Character) -> (ref: PersonRef, name: String)? {
        let familyTargets = character.family
            .filter(\.isAlive)
            .filter { !$0.isOwnChild }
            .map { (ref: PersonRef.family($0.id), name: $0.name) }
        let friendTargets = character.friends
            .map { (ref: PersonRef.friend($0.id), name: $0.name) }
        return (familyTargets + friendTargets).randomElement()
    }

    private func removeCrimeTarget(_ ref: PersonRef, from character: inout Character) {
        switch ref {
        case .family(let id):
            if let index = character.family.firstIndex(where: { $0.id == id }) {
                character.family[index].isAlive = false
                character.family[index].relationship = 0
            }
        case .friend(let id):
            character.friends.removeAll { $0.id == id }
        case .partner:
            character.partner = nil
        case .stranger:
            break
        }
    }

    /// Violence always leaves a specific mark — a bruise, a break, a stabbing,
    /// or (rarely, when guns are plausibly in play) a gunshot — rather than a
    /// flat, faceless health deduction.
    @discardableResult
    private func inflictViolentInjury(_ character: inout Character, allowGunshot: Bool) -> String {
        var candidates: [(id: String, weight: Int)] = [
            ("minor_injury", 55),
            ("broken_arm", 18),
            ("stab_wound", 20),
        ]
        if allowGunshot {
            candidates.append(("gunshot_wound", 7))
        }
        let stage = character.stage
        let available = candidates.filter { ConditionData.byID[$0.id]?.stages.contains(stage) == true }
        let pool = available.isEmpty ? [(id: "minor_injury", weight: 1)] : available
        var weighted: [String] = []
        for candidate in pool {
            weighted.append(contentsOf: Array(repeating: candidate.id, count: candidate.weight))
        }
        let chosenID = weighted.randomElement() ?? "minor_injury"
        grantCondition(&character, id: chosenID)
        attackTrigger += 1
        return ConditionData.byID[chosenID]?.name ?? "an injury"
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
        SoundManager.shared.play(.graduate)
        return "Congratulations! You graduated from \(universityName)."
    }

    func startInterview(for job: Job) -> JobInterviewSession? {
        guard let current = character else { return nil }
        guard !job.requiresDegree || current.educationLevel == .university else { return nil }
        guard JobData.passesBackgroundCheck(job, record: current.criminalRecord) else { return nil }

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
            SoundManager.shared.play(.fight)
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
        SoundManager.shared.play(hired ? .hired : .rejected)
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

    @discardableResult
    func performActivity(_ kind: ActivityKind) -> String {
        guard var current = character else { return "" }
        let name = current.firstName
        let result: String

        switch kind {
        case .gym:
            current.stats.adjust(happiness: Int.random(in: 2...6), looks: Int.random(in: 1...3))
            result = "\(name) hit the gym and feels great."
        case .reading:
            current.stats.adjust(happiness: 1, smarts: Int.random(in: 2...5))
            result = "\(name) read a book and learned something new."
        case .volunteering:
            current.stats.adjust(happiness: Int.random(in: 3...7))
            if !current.family.isEmpty {
                let index = Int.random(in: 0..<current.family.count)
                current.family[index].adjustRelationship(Int.random(in: 2...5))
            }
            result = "\(name) volunteered locally and felt fulfilled."
        case .meditating:
            current.stats.adjust(happiness: Int.random(in: 3...8))
            result = "\(name) meditated and feels calmer."
        case .hobby:
            current.stats.adjust(happiness: Int.random(in: 2...6), smarts: Bool.random() ? 1 : 0, looks: Bool.random() ? 1 : 0)
            result = "\(name) spent time on a hobby and had fun."
        }

        character = current
        SoundManager.shared.play(kind == .reading || kind == .meditating ? .tap : .cheer)
        return result
    }

    func migrationEligibilityMessage(to country: String) -> String? {
        guard let current = character else { return "Start a life before migrating." }
        guard !current.isInJail else { return "You can't exactly apply for a visa from prison." }
        guard !current.isFugitive else { return "No country will grant a visa to a known fugitive." }
        guard current.country != country else { return "You already live here." }
        guard current.stage != .infant, current.stage != .child else { return "Too young to migrate on your own." }
        let cost = MigrationData.migrationCost(for: CountryData.profile(for: country))
        guard current.cash >= cost else { return "You need $\(cost) saved up to afford the move." }
        return nil
    }

    func startMigration(to country: String) -> MigrationQuizSession? {
        guard migrationEligibilityMessage(to: country) == nil else { return nil }
        return MigrationData.quizSession(for: country)
    }

    func resolveMigration(_ session: MigrationQuizSession, answers: [Int]) -> MigrationOutcome {
        guard var current = character else {
            return MigrationOutcome(approved: false, destinationCountry: session.destinationCountry, amountCharged: 0, correctCount: 0, totalQuestions: session.questions.count)
        }

        // Carrying an illegal weapon across a border is its own problem,
        // independent of how well the visa interview went.
        if let weaponName = current.weaponName,
           WeaponData.all.first(where: { $0.name == weaponName })?.isIllegal == true,
           Double.random(in: 0...1) < 0.9 {
            arrest(&current, for: .weaponSmuggling, caughtAtScene: true, story: "Border agents found your \(weaponName) in your luggage.")
            character = current
            SoundManager.shared.playSequence([.alert, .rejected])
            return MigrationOutcome(
                approved: false,
                destinationCountry: session.destinationCountry,
                amountCharged: 0,
                correctCount: 0,
                totalQuestions: session.questions.count,
                note: "Border agents found your \(weaponName) during the search. You were detained on the spot and your visa application was denied."
            )
        }

        let correctCount = zip(session.questions, answers).filter { $0.0.correctIndex == $0.1 }.count
        let passedQuiz = correctCount * 2 >= session.questions.count

        // Wealthier, more developed countries run stricter background
        // checks — a longer criminal record makes them far more likely to
        // simply turn you away, even if the interview itself went fine.
        let destinationProfile = CountryData.profile(for: session.destinationCountry)
        let runsBackgroundCheck = destinationProfile.salaryMultiplier >= 0.8
        let backgroundCheckFails = runsBackgroundCheck && current.criminalRecord > 0
            && Double.random(in: 0...1) < min(0.9, Double(current.criminalRecord) * 0.12)

        if passedQuiz, current.cash >= session.cost, !backgroundCheckFails {
            current.cash -= session.cost
            current.country = session.destinationCountry
            current.job = nil
            current.yearsAtJob = 0
            character = current
            SoundManager.shared.play(.achievement)
            return MigrationOutcome(approved: true, destinationCountry: session.destinationCountry, amountCharged: session.cost, correctCount: correctCount, totalQuestions: session.questions.count)
        } else {
            let fee = min(current.cash, session.cost / 5)
            current.cash -= fee
            character = current
            SoundManager.shared.play(.rejected)
            let note = backgroundCheckFails
                ? "\(session.destinationCountry)'s background check flagged your criminal record. Visa denied regardless of your interview score."
                : nil
            return MigrationOutcome(approved: false, destinationCountry: session.destinationCountry, amountCharged: fee, correctCount: correctCount, totalQuestions: session.questions.count, note: note)
        }
    }

    // MARK: - Special careers

    /// The Job record that stands in for a rank on a career ladder, so pay,
    /// background checks and quitting all work like any other job.
    private func careerJob(for progress: CareerProgress) -> Job? {
        guard let track = progress.track, let rank = progress.rank, let role = progress.role else { return nil }
        return Job(
            id: track.jobID,
            title: "\(rank.title), \(role.title)",
            category: track.name,
            baseSalary: Int(Double(rank.salary) * role.payMultiplier),
            requiresDegree: false,
            isPartTime: false
        )
    }

    /// Why this career won't take you right now, or nil if you can apply.
    func careerJoinBlocker(_ track: CareerTrack) -> String? {
        guard let current = character else { return "Start a life first." }
        guard current.age >= track.minAge else { return "You must be \(track.minAge) to join." }
        guard current.age <= track.maxJoinAge else { return "Too old to start. They only take new recruits up to \(track.maxJoinAge)." }
        if track.requiresDegree, current.educationLevel != .university { return "You need a university degree." }
        guard current.stats.smarts >= track.minSmarts else { return "You need at least \(track.minSmarts) Smarts." }
        guard current.stats.health >= track.minHealth else { return "You need at least \(track.minHealth) Health to pass the physical." }
        if let maxRecord = track.maxRecord, current.criminalRecord > maxRecord {
            return maxRecord == 0 ? "They need a clean criminal record." : "Your criminal record is too long."
        }
        if current.isFugitive { return "They'd arrest a fugitive on the spot." }
        if current.activeCareer?.trackID == track.id { return "You're already in the \(track.name)." }
        return nil
    }

    func roleBlocker(_ role: CareerRole, in progress: CareerProgress) -> String? {
        guard let current = character, let track = progress.track else { return "" }
        if role.id == progress.roleID { return "Current role" }
        guard progress.rankIndex >= role.minRank else { return "Needs rank \(track.ranks[role.minRank].title)" }
        guard current.stats.smarts >= role.minSmarts else { return "Needs \(role.minSmarts) Smarts" }
        guard current.stats.health >= role.minHealth else { return "Needs \(role.minHealth) Health" }
        if role.requiresDegree, current.educationLevel != .university { return "Needs a degree" }
        return nil
    }

    func promotionBlocker(_ progress: CareerProgress) -> String? {
        guard let current = character else { return "" }
        return promotionBlocker(progress, for: current)
    }

    private func promotionBlocker(_ progress: CareerProgress, for current: Character) -> String? {
        guard let next = progress.nextRank else { return "You're at the top. There's nowhere higher to go." }
        guard progress.yearsInRank >= next.minYears else {
            let left = next.minYears - progress.yearsInRank
            return "\(left) more year\(left == 1 ? "" : "s") in your current rank first."
        }
        guard progress.performance >= next.minPerformance else { return "Your performance needs to be at least \(next.minPerformance)." }
        if next.requiresDegree, current.educationLevel != .university { return "\(next.title) requires a university degree." }
        guard current.stats.smarts >= next.minSmarts else { return "\(next.title) needs at least \(next.minSmarts) Smarts." }
        return nil
    }

    @discardableResult
    func joinCareer(_ track: CareerTrack, roleID: String) -> String {
        if let blocker = careerJoinBlocker(track) { return blocker }
        guard var current = character, let role = track.role(roleID) else { return "" }

        let chance = min(0.97, track.acceptChance
            + Double(current.stats.health - 50) / 300.0
            + Double(current.stats.smarts - 50) / 300.0)
        guard Double.random(in: 0...1) < chance else {
            SoundManager.shared.play(.rejected)
            return "The \(track.name) turned down your application this time. Try again later."
        }

        let progress = CareerProgress(trackID: track.id, roleID: role.id)
        current.careerProgress = progress
        current.job = careerJob(for: progress)
        current.yearsAtJob = 0
        current.stats.adjust(happiness: Int.random(in: 3...8))
        character = current
        SoundManager.shared.play(.hired)
        let rankTitle = track.ranks[0].title
        let text = "You joined the \(track.name) as \(Self.article(for: rankTitle)) \(rankTitle) in \(role.title)."
        var log = yearLog
        log.append(LogEntry(text: text, isAlert: false))
        yearLog = log
        return text
    }

    @discardableResult
    func workHard() -> String {
        guard var current = character, var progress = current.activeCareer else { return "" }
        guard !progress.workedHardThisYear else { return "You've already been putting in extra hours this year." }
        progress.workedHardThisYear = true
        let gain = Int.random(in: 8...14)
        progress.performance = min(100, progress.performance + gain)
        current.stats.adjust(health: -Int.random(in: 0...2), happiness: -Int.random(in: 2...5))
        current.careerProgress = progress
        character = current
        SoundManager.shared.play(.tap)
        return "You put in long hours and your bosses noticed. Performance +\(gain)."
    }

    @discardableResult
    func seekPromotion() -> String {
        guard var current = character, var progress = current.activeCareer else { return "" }
        guard !progress.triedPromotionThisYear else { return "You already went for a promotion this year. Wait until next year." }
        if let blocker = promotionBlocker(progress) { return blocker }
        progress.triedPromotionThisYear = true

        let next = progress.nextRank!
        let chance = min(0.95, 0.35 + Double(progress.performance - next.minPerformance) / 40.0)
        if Double.random(in: 0...1) < chance {
            promote(&current, progress: &progress)
            character = current
            SoundManager.shared.play(.achievement)
            let text = "Promoted! You're now \(Self.article(for: next.title)) \(next.title)."
            var log = yearLog
            log.append(LogEntry(text: text, isAlert: false))
            yearLog = log
            return text
        }
        progress.performance = max(0, progress.performance - 5)
        current.stats.adjust(happiness: -Int.random(in: 2...5))
        current.careerProgress = progress
        character = current
        SoundManager.shared.play(.rejected)
        return "The promotion went to someone else. Keep your performance up and try again next year."
    }

    @discardableResult
    func switchRole(to roleID: String) -> String {
        guard var current = character, var progress = current.activeCareer,
              let role = progress.track?.role(roleID) else { return "" }
        if let blocker = roleBlocker(role, in: progress) { return blocker }
        progress.roleID = roleID
        current.careerProgress = progress
        current.job = careerJob(for: progress)
        character = current
        SoundManager.shared.play(.success)
        return "You transferred to \(role.title)."
    }

    private static func article(for word: String) -> String {
        guard let first = word.lowercased().first else { return "a" }
        return "aeiou".contains(first) ? "an" : "a"
    }

    private func promote(_ character: inout Character, progress: inout CareerProgress) {
        progress.rankIndex += 1
        progress.yearsInRank = 0
        progress.performance = max(40, progress.performance - 15)
        character.careerProgress = progress
        character.job = careerJob(for: progress)
        character.stats.adjust(happiness: Int.random(in: 5...10))
    }

    /// A working year on a career ladder: performance moves, things happen
    /// on the job, dangerous roles get dangerous, and promotions come up.
    private func handleCareerTrack(_ character: inout Character, log: inout [LogEntry]) {
        guard var progress = character.activeCareer, let track = progress.track, let role = progress.role else { return }
        let name = character.firstName

        progress.yearsInRank += 1
        progress.yearsInCareer += 1
        let drift = (character.stats.smarts - 50) / 10
            + (character.stats.happiness - 50) / 15
            + Int.random(in: -6...6)
            + (progress.workedHardThisYear ? 2 : -2)
        progress.performance = min(100, max(0, progress.performance + drift))
        progress.workedHardThisYear = false
        progress.triedPromotionThisYear = false

        let violentTracks: Set<String> = ["army", "police", "fire", "law"]
        if Double.random(in: 0...1) < role.risk * 0.3 {
            if Double.random(in: 0...1) < role.risk * 0.05 {
                character.careerProgress = progress
                character.isAlive = false
                character.causeOfDeath = track.deathCause
                attackTrigger += 1
                log.append(LogEntry(text: "\(name) \(track.dangerText) and didn't make it home.", isAlert: true))
                return
            }
            let injury: String
            if violentTracks.contains(track.id) {
                injury = inflictViolentInjury(&character, allowGunshot: track.id == "army" || track.id == "police")
            } else {
                grantCondition(&character, id: "minor_injury")
                injury = "Minor Injury"
            }
            attackTrigger += 1
            progress.performance = min(100, progress.performance + 5)
            var text = "\(name) \(track.dangerText) and came away with \(injury.lowercased())."
            if track.id == "army" || track.id == "police" || track.id == "fire", Double.random(in: 0...1) < 0.4 {
                progress.medals += 1
                progress.performance = min(100, progress.performance + 8)
                text += " They were awarded a medal for bravery."
            }
            log.append(LogEntry(text: text, isAlert: true))
        } else {
            let roll = Double.random(in: 0...1)
            if roll < 0.35, let event = track.goodEvents.randomElement() {
                progress.performance = min(100, progress.performance + event.performance)
                character.stats.adjust(happiness: event.happiness)
                log.append(LogEntry(text: "\(name) \(event.text).", isAlert: false))
            } else if roll < 0.5, let event = track.badEvents.randomElement() {
                progress.performance = max(0, progress.performance + event.performance)
                character.stats.adjust(happiness: event.happiness)
                log.append(LogEntry(text: "\(name) \(event.text).", isAlert: true))
            }
        }

        character.careerProgress = progress
        if promotionBlocker(progress, for: character) == nil, Double.random(in: 0...1) < 0.45, let next = progress.nextRank {
            promote(&character, progress: &progress)
            log.append(LogEntry(text: "\(name) was promoted to \(next.title)!", isAlert: false))
        }

        if progress.performance < 15, Double.random(in: 0...1) < 0.4 {
            log.append(LogEntry(text: "\(name) was let go from the \(track.name) for poor performance.", isAlert: true))
            character.job = nil
            character.yearsAtJob = 0
        }
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

        // Career ladders move by promotion instead of flat raises.
        if character.activeCareer != nil {
            handleCareerTrack(&character, log: &log)
            return
        }

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
        case .partner:
            return character.partner?.relationship ?? 0
        case .stranger:
            return 0
        }
    }

    private func adjustRelationship(_ character: inout Character, ref: PersonRef, by delta: Int) {
        switch ref {
        case .family(let id):
            if let index = character.family.firstIndex(where: { $0.id == id }) {
                character.family[index].adjustRelationship(delta, ceiling: character.family[index].history.relationshipCeiling)
            }
        case .friend(let id):
            if let index = character.friends.firstIndex(where: { $0.id == id }) {
                character.friends[index].adjustRelationship(delta, ceiling: character.friends[index].history.relationshipCeiling)
            }
        case .partner:
            if let ceiling = character.partner?.history.relationshipCeiling {
                character.partner?.adjustRelationship(delta, ceiling: ceiling)
            }
        case .stranger:
            break
        }
    }

    /// How many of this year's shared interaction slots remain for this
    /// person — spamming the same action (or any action) has a hard cap.
    func remainingInteractions(for ref: PersonRef) -> Int {
        guard let current = character else { return 0 }
        return relationshipHistory(current, ref: ref)?.remainingThisYear ?? RelationshipHistory.yearlyBudget
    }

    func isInBadMood(_ ref: PersonRef) -> Bool {
        guard let current = character else { return false }
        return relationshipHistory(current, ref: ref)?.isInBadMood ?? false
    }

    func isInGreatMood(_ ref: PersonRef) -> Bool {
        guard let current = character else { return false }
        return relationshipHistory(current, ref: ref)?.isInGreatMood ?? false
    }

    private func relationshipHistory(_ character: Character, ref: PersonRef) -> RelationshipHistory? {
        switch ref {
        case .family(let id):
            return character.family.first(where: { $0.id == id })?.history
        case .friend(let id):
            return character.friends.first(where: { $0.id == id })?.history
        case .partner:
            return character.partner?.history
        case .stranger:
            return nil
        }
    }

    /// Applies a mutation to a person's interaction history regardless of
    /// whether they're family, a friend, or a partner.
    private func updateHistory(_ character: inout Character, ref: PersonRef, _ mutate: (inout RelationshipHistory) -> Void) {
        switch ref {
        case .family(let id):
            if let index = character.family.firstIndex(where: { $0.id == id }) {
                mutate(&character.family[index].history)
            }
        case .friend(let id):
            if let index = character.friends.firstIndex(where: { $0.id == id }) {
                mutate(&character.friends[index].history)
            }
        case .partner:
            if character.partner != nil {
                mutate(&character.partner!.history)
            }
        case .stranger:
            break
        }
    }

    private func resetRelationshipHistories(_ character: inout Character) {
        for index in character.family.indices {
            character.family[index].history.resetYearly()
        }
        for index in character.friends.indices {
            character.friends[index].history.resetYearly()
        }
        character.partner?.history.resetYearly()
    }

    private func personName(_ character: Character, ref: PersonRef) -> String? {
        switch ref {
        case .family(let id):
            return character.family.first(where: { $0.id == id })?.name
        case .friend(let id):
            return character.friends.first(where: { $0.id == id })?.name
        case .partner:
            return character.partner?.name
        case .stranger:
            return nil
        }
    }

    private func familyLabel(_ character: Character, ref: PersonRef) -> String? {
        guard case .family(let id) = ref else { return nil }
        return character.family.first(where: { $0.id == id })?.relation.rawValue
    }

    private func friendVolatility(_ character: Character, ref: PersonRef) -> Int {
        guard case .friend(let id) = ref else { return 10 }
        return character.friends.first(where: { $0.id == id })?.volatility ?? 10
    }

    private func isFriend(_ ref: PersonRef) -> Bool {
        if case .friend = ref { return true }
        return false
    }

    private func resolveMoneyRequest(_ event: SocialEvent, accepted: Bool, character: inout Character) -> LogEntry {
        if accepted {
            guard character.cash >= event.amount else {
                adjustRelationship(&character, ref: event.actorRef, by: -4)
                SoundManager.shared.play(.rejected)
                return LogEntry(text: "You tried to help \(event.actorName), but you didn't have enough cash. They were disappointed.", isAlert: true)
            }
            character.cash -= event.amount
            let gain = Int.random(in: 8...16)
            adjustRelationship(&character, ref: event.actorRef, by: gain)
            character.stats.adjust(happiness: 2)
            SoundManager.shared.play(.cheer)
            return LogEntry(text: "You gave \(event.actorName) $\(event.amount). Relationship +\(gain).", isAlert: false)
        }

        let loss = Int.random(in: 6...18)
        adjustRelationship(&character, ref: event.actorRef, by: -loss)
        let volatility = friendVolatility(character, ref: event.actorRef)
        let fightChance = isFriend(event.actorRef) ? max(0.01, Double(volatility - 72) / 180.0) : 0
        if Double.random(in: 0...1) < fightChance {
            let injuryName = inflictViolentInjury(&character, allowGunshot: false)
            character.stats.adjust(happiness: -Int.random(in: 3...8))
            if character.stats.health <= 0, Double.random(in: 0...1) < 0.16 {
                character.isAlive = false
                character.causeOfDeath = "a fight with \(event.actorName)"
                SoundManager.shared.playSequence([.ouch, .death])
                return LogEntry(text: "You refused \(event.actorName)'s cash request. They snapped, started a fight, and you died from your injuries.", isAlert: true)
            }
            SoundManager.shared.playSequence([.ouch, .fight])
            return LogEntry(text: "You said no to \(event.actorName). They snapped and started a fight, leaving you with \(injuryName.lowercased()). Relationship -\(loss).", isAlert: true)
        }
        SoundManager.shared.play(.sad)
        return LogEntry(text: "You said no to \(event.actorName). They took it badly. Relationship -\(loss).", isAlert: true)
    }

    private func resolveFamilyEmergency(_ event: SocialEvent, accepted: Bool, character: inout Character) -> LogEntry {
        if accepted {
            guard character.cash >= event.amount else {
                adjustRelationship(&character, ref: event.actorRef, by: -5)
                SoundManager.shared.play(.rejected)
                return LogEntry(text: "You wanted to help \(event.actorName), but couldn't afford it. Relationship -5.", isAlert: true)
            }
            character.cash -= event.amount
            let gain = Int.random(in: 12...22)
            adjustRelationship(&character, ref: event.actorRef, by: gain)
            character.stats.adjust(happiness: 3)
            SoundManager.shared.play(.cheer)
            return LogEntry(text: "You helped \(event.actorName) through an emergency for $\(event.amount). Relationship +\(gain).", isAlert: false)
        }

        let loss = Int.random(in: 10...24)
        adjustRelationship(&character, ref: event.actorRef, by: -loss)
        character.stats.adjust(happiness: -Int.random(in: 1...5))

        if case .family(let id) = event.actorRef,
           let index = character.family.firstIndex(where: { $0.id == id }),
           character.family[index].relationship < 18,
           Double.random(in: 0...1) < 0.08 {
            character.family[index].isAlive = false
            SoundManager.shared.play(.death)
            return LogEntry(text: "You refused to help \(event.actorName). Later that year, they passed away after things got worse.", isAlert: true)
        }

        SoundManager.shared.play(.sad)
        return LogEntry(text: "You refused to help \(event.actorName) with the emergency. Relationship -\(loss).", isAlert: true)
    }

    private func resolveFightBackup(_ event: SocialEvent, accepted: Bool, character: inout Character) -> LogEntry {
        if !accepted {
            let loss = Int.random(in: 8...18)
            adjustRelationship(&character, ref: event.actorRef, by: -loss)
            SoundManager.shared.play(.sad)
            return LogEntry(text: "You stayed out of \(event.actorName)'s fight. They felt abandoned. Relationship -\(loss).", isAlert: true)
        }

        let actorRelationship = relationshipValue(character, ref: event.actorRef)
        let gain = Int.random(in: 6...14)
        adjustRelationship(&character, ref: event.actorRef, by: gain)
        if let targetRef = event.targetRef {
            adjustRelationship(&character, ref: targetRef, by: -Int.random(in: 10...22))
        }

        let injuryChance = max(0.12, 0.38 - Double(actorRelationship) / 350.0)
        guard Double.random(in: 0...1) < injuryChance else {
            character.stats.adjust(happiness: 2)
            SoundManager.shared.play(.success)
            return LogEntry(text: "You backed up \(event.actorName) and the confrontation ended without you getting hurt. Relationship +\(gain).", isAlert: false)
        }

        let injuryName = inflictViolentInjury(&character, allowGunshot: false)
        character.stats.adjust(happiness: -Int.random(in: 2...8))

        let deathRisk = character.stats.health <= 0 ? 0.18 : 0.015
        if Double.random(in: 0...1) < deathRisk {
            character.isAlive = false
            character.causeOfDeath = "injuries from a fight"
            SoundManager.shared.playSequence([.ouch, .death])
            return LogEntry(text: "You backed up \(event.actorName), but the fight turned deadly. You died from your injuries.", isAlert: true)
        }

        SoundManager.shared.play(.ouch)
        let target = event.targetName ?? "someone they knew"
        return LogEntry(text: "You helped \(event.actorName) fight \(target) and came away with \(injuryName.lowercased()), but they trust you more. Relationship +\(gain).", isAlert: true)
    }

    private func resolveHangoutInvite(_ event: SocialEvent, accepted: Bool, character: inout Character) -> LogEntry {
        if accepted {
            let gain = Int.random(in: 5...12)
            adjustRelationship(&character, ref: event.actorRef, by: gain)
            character.stats.adjust(happiness: Int.random(in: 4...10), smarts: Bool.random() ? 1 : 0)
            let volatility = friendVolatility(character, ref: event.actorRef)
            if Double.random(in: 0...1) < Double(volatility) / 420.0 {
                grantCondition(&character, id: "minor_injury")
                SoundManager.shared.play(.ouch)
                return LogEntry(text: "You went out with \(event.actorName). It was fun, but got a little chaotic and you picked up some minor injuries. Relationship +\(gain).", isAlert: true)
            }
            SoundManager.shared.play(.party)
            return LogEntry(text: "You spent the day with \(event.actorName). Happiness rose and Relationship +\(gain).", isAlert: false)
        }

        let loss = Int.random(in: 2...8)
        adjustRelationship(&character, ref: event.actorRef, by: -loss)
        character.stats.adjust(smarts: Bool.random() ? 2 : 0)
        SoundManager.shared.play(.tap)
        return LogEntry(text: "You skipped plans with \(event.actorName). Relationship -\(loss), but you had time for yourself.", isAlert: loss > 5)
    }

    private func resolveRiskyScheme(_ event: SocialEvent, accepted: Bool, character: inout Character) -> LogEntry {
        let volatility = friendVolatility(character, ref: event.actorRef)
        if !accepted {
            let loss = Int.random(in: 6...14)
            adjustRelationship(&character, ref: event.actorRef, by: -loss)
            character.stats.adjust(smarts: 1)
            SoundManager.shared.play(.tap)
            return LogEntry(text: "You refused \(event.actorName)'s risky plan. Relationship -\(loss), but it was probably the smart call.", isAlert: true)
        }

        let gain = Int.random(in: 8...16)
        adjustRelationship(&character, ref: event.actorRef, by: gain)
        let successChance = max(0.18, 0.62 - Double(volatility) / 260.0 + Double(character.stats.smarts) / 500.0)
        if Double.random(in: 0...1) < successChance {
            let cash = localized(Int.random(in: 10...75), for: character)
            character.cash += cash
            character.stats.adjust(happiness: Int.random(in: 3...9))
            SoundManager.shared.play(.success)
            return LogEntry(text: "\(event.title) worked out. You made $\(cash) and Relationship +\(gain).", isAlert: false)
        }

        let fine = min(character.cash, localized(Int.random(in: 0...45), for: character))
        character.cash -= fine
        let injuryName = inflictViolentInjury(&character, allowGunshot: false)
        character.stats.adjust(happiness: -Int.random(in: 2...8))
        if character.stats.health <= 0, Double.random(in: 0...1) < 0.12 {
            character.isAlive = false
            character.causeOfDeath = "a reckless scheme with \(event.actorName)"
            SoundManager.shared.playSequence([.ouch, .death])
            return LogEntry(text: "You joined \(event.actorName)'s reckless plan. It went catastrophically wrong, and you died.", isAlert: true)
        }
        SoundManager.shared.playSequence([.ouch, .alert])
        let fineText = fine > 0 ? ", and it cost you $\(fine)" : ""
        return LogEntry(text: "\(event.title) went wrong. You came away with \(injuryName.lowercased())\(fineText), but Relationship +\(gain).", isAlert: true)
    }

    private func resolveCoverStory(_ event: SocialEvent, accepted: Bool, character: inout Character) -> LogEntry {
        if accepted {
            let gain = Int.random(in: 7...15)
            adjustRelationship(&character, ref: event.actorRef, by: gain)
            if let targetRef = event.targetRef {
                adjustRelationship(&character, ref: targetRef, by: -Int.random(in: 4...12))
            }
            character.stats.adjust(happiness: -Int.random(in: 0...4))
            SoundManager.shared.play(.success)
            let target = event.targetName ?? "someone else"
            return LogEntry(text: "You covered for \(event.actorName) with \(target). Relationship +\(gain), but the lie made things messier.", isAlert: true)
        }

        let loss = Int.random(in: 5...13)
        adjustRelationship(&character, ref: event.actorRef, by: -loss)
        character.stats.adjust(smarts: 1)
        SoundManager.shared.play(.tap)
        return LogEntry(text: "You refused to lie for \(event.actorName). Relationship -\(loss), but you kept out of the drama.", isAlert: true)
    }

    private func resolveGangRecruitment(_ event: SocialEvent, accepted: Bool, character: inout Character) -> LogEntry {
        if accepted {
            character.gangName = event.actorName
            character.policeHeat += 8
            character.stats.adjust(happiness: Int.random(in: 2...8), smarts: -Int.random(in: 0...2))
            SoundManager.shared.play(.danger)
            return LogEntry(text: "You joined up with \(event.actorName)'s crew. There's no easy way out now.", isAlert: true)
        }

        // Refusing a recruiter is a gamble — most walk away annoyed, but some
        // don't take no for an answer.
        let roll = Double.random(in: 0...1)
        if roll < 0.12 {
            character.isAlive = false
            character.causeOfDeath = "refusing to join \(event.actorName)'s gang"
            attackTrigger += 1
            SoundManager.shared.playSequence([.ouch, .death])
            return LogEntry(text: "\(event.actorName) did not take rejection well. Their crew made sure you'd never refuse anyone again.", isAlert: true)
        }
        if roll < 0.40 {
            let injuryName = inflictViolentInjury(&character, allowGunshot: false)
            character.stats.adjust(happiness: -Int.random(in: 5...14))
            SoundManager.shared.playSequence([.ouch, .alert])
            return LogEntry(text: "\(event.actorName) had you roughed up as a warning for turning them down, leaving you with \(injuryName.lowercased()).", isAlert: true)
        }

        character.stats.adjust(happiness: -Int.random(in: 1...5))
        SoundManager.shared.play(.tap)
        return LogEntry(text: "You turned \(event.actorName) down. They glared, but let it go — for now.", isAlert: false)
    }

    private func resolveJobOffer(_ event: SocialEvent, accepted: Bool, character: inout Character) -> LogEntry {
        guard accepted else {
            SoundManager.shared.play(.tap)
            return LogEntry(text: "You passed on \(event.actorName)'s offer.", isAlert: false)
        }

        let record = character.criminalRecord
        let candidates = JobData.available(stage: character.stage, educationLevel: character.educationLevel, country: character.country)
            .filter { JobData.passesBackgroundCheck($0, record: record) }
        guard let job = candidates.randomElement() else {
            SoundManager.shared.play(.rejected)
            return LogEntry(text: "\(event.actorName)'s lead fell through — nothing suitable panned out.", isAlert: true)
        }

        character.job = job
        character.yearsAtJob = 0
        character.stats.adjust(happiness: Int.random(in: 3...8))
        SoundManager.shared.play(.hired)
        return LogEntry(text: "\(event.actorName) came through — you're now working as \(job.title).", isAlert: false)
    }

    private func resolveGangHeist(_ event: SocialEvent, accepted: Bool, character: inout Character) -> LogEntry {
        guard accepted else {
            // Turning down the crew rarely ends well.
            if Double.random(in: 0...1) < 0.25 {
                let injuryName = inflictViolentInjury(&character, allowGunshot: false)
                character.stats.adjust(happiness: -Int.random(in: 5...12))
                SoundManager.shared.playSequence([.ouch, .alert])
                return LogEntry(text: "\(event.actorName) didn't like being turned down. You came away with \(injuryName.lowercased()) as a reminder of your place.", isAlert: true)
            }
            SoundManager.shared.play(.tap)
            return LogEntry(text: "You sat this one out. \(event.actorName) wasn't thrilled, but let it go.", isAlert: false)
        }

        let weaponBonus = Double(character.weapon?.power ?? 0) * 0.015
        let successChance = 0.42 + Double(character.stats.smarts) / 500.0 + weaponBonus
        if Double.random(in: 0...1) < successChance {
            let take = localized(Int.random(in: 800...4000), for: character)
            character.cash += take
            character.policeHeat += 25
            character.stats.adjust(happiness: Int.random(in: 4...10))
            openCaseMaybe(&character, crime: .bankRobbery, chance: 0.4, masked: character.isMasked)
            SoundManager.shared.play(.achievement)
            return LogEntry(text: "The job with \(event.actorName) went off clean. Your cut came to $\(take).", isAlert: false)
        }

        SoundManager.shared.playSequence([.alert, .rejected])
        arrest(&character, for: .bankRobbery, caughtAtScene: true, story: "Alarms went off mid-job and the police had the building surrounded.")
        return LogEntry(text: "The job with \(event.actorName) went south. Alarms, sirens — you were caught at the scene.", isAlert: true)
    }

    func canAskOut(_ ref: PersonRef) -> Bool {
        guard let current = character, current.partner == nil,
              current.stage != .infant, current.stage != .child else { return false }
        guard case .friend = ref else { return false }
        return relationshipValue(current, ref: ref) >= 55
    }

    @discardableResult
    func askOut(_ ref: PersonRef) -> String {
        guard var current = character, current.partner == nil,
              case .friend(let id) = ref,
              let index = current.friends.firstIndex(where: { $0.id == id }) else { return "" }

        let friend = current.friends[index]
        let chance = min(0.9, 0.3 + Double(friend.relationship) / 150.0)
        if Double.random(in: 0...1) < chance {
            current.friends.remove(at: index)
            current.partner = Partner(name: friend.name, gender: friend.gender, relationship: min(100, friend.relationship + 10))
            current.stats.adjust(happiness: Int.random(in: 5...12))
            character = current
            SoundManager.shared.play(.cheer)
            return "\(friend.name) said yes! You're officially together."
        } else {
            current.friends[index].adjustRelationship(-Int.random(in: 5...15))
            character = current
            SoundManager.shared.play(.rejected)
            return "\(friend.name) turned you down. Awkward, but you're still friends."
        }
    }

    @discardableResult
    func propose() -> String {
        guard var current = character, var partner = current.partner, !partner.isMarried else { return "" }

        let chance = min(0.95, 0.3 + Double(partner.relationship) / 120.0)
        if Double.random(in: 0...1) < chance {
            partner.isMarried = true
            partner.adjustRelationship(10)
            current.partner = partner
            current.stats.adjust(happiness: Int.random(in: 10...20))
            character = current
            SoundManager.shared.play(.achievement)
            return "\(partner.name) said yes! You're married."
        } else {
            partner.adjustRelationship(-Int.random(in: 10...20))
            current.partner = partner
            character = current
            SoundManager.shared.play(.rejected)
            return "\(partner.name) wasn't ready for that. They turned down your proposal."
        }
    }

    @discardableResult
    func breakUp() -> String {
        guard var current = character, let partner = current.partner else { return "" }
        current.partner = nil
        current.stats.adjust(happiness: -Int.random(in: 10...20))
        character = current
        SoundManager.shared.play(.heartbreak)
        return partner.isMarried ? "You and \(partner.name) got divorced." : "You and \(partner.name) broke up."
    }

    func tryForBabyEligibilityMessage() -> String? {
        guard let current = character else { return "Start a life first." }
        guard current.partner != nil else { return "You need a partner to try for a baby." }
        guard current.stage == .adult, current.age >= 18, current.age <= 50 else {
            return "You're outside the age where this is likely to work."
        }
        if let blocked = budgetMessage(current, ref: .partner) { return blocked }
        return nil
    }

    @discardableResult
    func tryForBaby() -> String {
        guard var current = character, let partner = current.partner else { return "" }
        if let blocked = tryForBabyEligibilityMessage() { return blocked }

        updateHistory(&current, ref: .partner) { $0.recordUse("tryForBaby") }

        let chance = min(0.85, 0.25 + Double(partner.relationship) / 150.0)
        guard Double.random(in: 0...1) < chance else {
            character = current
            SoundManager.shared.play(.tap)
            return "It didn't happen this time. Maybe try again next year."
        }

        let region = CountryData.profile(for: current.country).region
        let gender: Gender = Bool.random() ? .male : .female
        let name = "\(NameData.randomFirstName(for: gender, region: region)) \(current.lastName)"
        current.family.append(FamilyMember(name: name, relation: gender == .male ? .son : .daughter, relationship: 70, age: 0))
        current.stats.adjust(happiness: Int.random(in: 8...16))
        character = current
        SoundManager.shared.play(.achievement)
        return "You had a \(gender == .male ? "son" : "daughter"), \(name)! Congratulations."
    }

    func adoptChildEligibilityMessage() -> String? {
        guard let current = character else { return "Start a life first." }
        guard current.stage == .adult, current.age >= 21 else { return "You need to be at least 21 to adopt." }
        let cost = localized(2500, for: current)
        guard current.cash >= cost else { return "You need $\(cost) to cover adoption costs." }
        return nil
    }

    @discardableResult
    func adoptChild() -> String {
        guard var current = character else { return "" }
        if let blocked = adoptChildEligibilityMessage() { return blocked }

        let cost = localized(2500, for: current)
        current.cash -= cost
        let region = CountryData.profile(for: current.country).region
        let gender: Gender = Bool.random() ? .male : .female
        let age = Int.random(in: 0...6)
        let name = "\(NameData.randomFirstName(for: gender, region: region)) \(current.lastName)"
        current.family.append(FamilyMember(name: name, relation: gender == .male ? .son : .daughter, relationship: 60, age: age))
        current.stats.adjust(happiness: Int.random(in: 8...16))
        character = current
        SoundManager.shared.play(.achievement)
        return "You adopted \(name)! Welcome to the family."
    }

    /// Ages every son/daughter by a year, drifts their relationship gently,
    /// and narrates a couple of one-off milestones. Mirrors `handleFriends`/
    /// `handlePartner` in shape, but children never leave `character.family`
    /// — at 18 they just get a narration beat, same as everyone else who
    /// stays in the family list for life.
    private func handleChildren(_ character: inout Character, log: inout [LogEntry]) {
        for index in character.family.indices {
            guard character.family[index].isOwnChild, character.family[index].isAlive else { continue }
            character.family[index].age += 1
            let newAge = character.family[index].age
            let name = character.family[index].name

            character.family[index].adjustRelationship(Int.random(in: -3...5))

            switch newAge {
            case 5:
                log.append(LogEntry(text: "\(name) started school.", isAlert: false))
            case 18:
                log.append(LogEntry(text: "\(name) moved out to start their own life.", isAlert: false))
            default:
                break
            }
        }
    }

    private func handlePartner(_ character: inout Character, log: inout [LogEntry]) {
        guard var partner = character.partner else { return }
        partner.yearsTogether += 1

        if Double.random(in: 0...1) < 0.3 {
            partner.adjustRelationship(Int.random(in: -4...6))
        }

        if !partner.isMarried, partner.relationship <= 5, Double.random(in: 0...1) < 0.4 {
            log.append(LogEntry(text: "\(partner.name) ended things with you. The relationship had run its course.", isAlert: true))
            character.partner = nil
            SoundManager.shared.play(.heartbreak)
            return
        }

        if Double.random(in: 0...1) < 0.1 {
            character.stats.adjust(happiness: Int.random(in: 2...6))
            partner.adjustRelationship(Int.random(in: 2...6))
            log.append(LogEntry(text: "You and \(partner.name) had a wonderful \(partner.isMarried ? "anniversary" : "date night").", isAlert: false))
        }

        character.partner = partner
    }

    private func handleFriends(_ character: inout Character, log: inout [LogEntry]) {
        var remaining: [Friend] = []
        for var friend in character.friends {
            let drift = friend.volatility > 75 ? Int.random(in: -6...7) : Int.random(in: -3...5)
            friend.adjustRelationship(drift)
            let leaveChance = friendLeavingChance(relationship: friend.relationship) * (friend.volatility > 82 ? 0.55 : 1.0)
            if friend.relationship <= 0 || Double.random(in: 0...1) < leaveChance {
                log.append(LogEntry(text: "You and \(friend.name) drifted apart and are no longer friends.", isAlert: true))
            } else {
                remaining.append(friend)
            }
        }
        character.friends = remaining

        if character.stage != .infant, character.friends.count < 5, Double.random(in: 0...1) < 0.25 {
            let gender: Gender = Bool.random() ? .male : .female
            let region = CountryData.profile(for: character.country).region
            let name = "\(NameData.randomFirstName(for: gender, region: region)) \(NameData.randomLastName(region: region))"
            character.friends.append(Friend(name: name, gender: gender, relationship: Int.random(in: 40...70)))
            log.append(LogEntry(text: "You made a new friend, \(name)!", isAlert: false))
        }
    }

    private func friendLeavingChance(relationship: Int) -> Double {
        switch relationship {
        case ..<15: return 0.36
        case 15..<30: return 0.22
        case 30..<50: return 0.10
        case 50..<70: return 0.04
        case 70..<90: return 0.015
        default: return 0.004
        }
    }

    private func socialScenario(
        kind: SocialEventKind,
        actor: String,
        actorLabel: String,
        target: String?,
        stage: LifeStage
    ) -> (title: String, message: String, accept: String, decline: String, log: String) {
        let targetName = target ?? "someone else"
        switch kind {
        case .hangoutInvite:
            let scenarios = [
                ("Arcade invite", "\(actor) wants you to sneak extra time at the arcade after school.", "Go To Arcade", "Head Home", "\(actor) invited you to the arcade."),
                ("Late cinema plan", "\(actor) found a way into a late movie and wants you to come along.", "See The Movie", "Skip It", "\(actor) tried to pull you into a late movie."),
                ("Park meetup", "\(actor) wants to meet at the park and talk about everything going on.", "Meet Up", "Stay Home", "\(actor) asked you to meet at the park."),
                ("Pickup game", "\(actor) wants you on their side for a rough pickup game.", "Play", "Sit Out", "\(actor) invited you to a pickup game."),
                ("Study pact", "\(actor) wants to study together before a big test.", "Study Together", "Study Alone", "\(actor) asked you to study together.")
            ]
            return scenarios.randomElement()!
        case .riskyScheme:
            let scenarios = [
                ("Closed cinema break-in", "\(actor) wants to sneak into the closed cinema after hours and look around.", "Sneak In", "Walk Away", "\(actor) pitched sneaking into the closed cinema."),
                ("Shoplift challenge", "\(actor) dares you to steal headphones from a corner shop.", "Take The Dare", "Refuse Dare", "\(actor) dared you to shoplift."),
                ("Rooftop shortcut", "\(actor) says the fastest way across town is over an abandoned rooftop.", "Climb Up", "Use The Street", "\(actor) wanted to cross an abandoned rooftop."),
                ("Fake ticket scam", "\(actor) wants to sell fake concert tickets outside the station.", "Join Scam", "Say No", "\(actor) suggested a fake ticket scam."),
                ("Joyride offer", "\(actor) has keys to a car that is definitely not theirs.", "Get In", "Leave", "\(actor) offered you a joyride.")
            ]
            return scenarios.randomElement()!
        case .coverStory:
            let scenarios = [
                ("Broken window lie", "\(actor) broke a window and wants you to tell \(targetName) it was an accident you caused.", "Take Blame", "Refuse", "\(actor) wanted you to cover for a broken window."),
                ("Missed curfew cover", "\(actor) missed curfew and wants you to say they were with you.", "Cover Curfew", "Tell No Lie", "\(actor) needed a curfew cover story."),
                ("Skipped shift excuse", "\(actor) skipped something important and wants you to make up an excuse to \(targetName).", "Make Excuse", "Stay Honest", "\(actor) asked for a fake excuse."),
                ("Secret relationship", "\(actor) is hiding a secret relationship and wants you to lie to \(targetName).", "Keep Secret", "Refuse", "\(actor) asked you to hide a relationship."),
                ("Stolen snack blame", "\(actor) took snacks from home and wants you to blame \(targetName).", "Shift Blame", "No Way", "\(actor) tried to get you into a snack theft lie.")
            ]
            return scenarios.randomElement()!
        case .fightBackup:
            let scenarios = [
                ("Bus stop confrontation", "\(actor) wants you beside them when they confront \(targetName) at the bus stop.", "Stand With Them", "Stay Away", "\(actor) wanted backup at the bus stop."),
                ("Behind-gym fight", "\(actor) says \(targetName) will be behind the gym and wants you there.", "Show Up", "Avoid It", "\(actor) asked you into a behind-gym fight."),
                ("Skate park beef", "\(actor) got into trouble at the skate park and wants you to help settle it.", "Back Them", "Keep Out", "\(actor) pulled you toward skate park drama."),
                ("Party argument", "\(actor) wants you to help face \(targetName) after a party argument.", "Go With Them", "Stay Home", "\(actor) asked for help after a party argument."),
                ("Sibling feud", "\(actor) wants you to help intimidate \(targetName) during a family feud.", "Get Involved", "Refuse", "\(actor) tried to drag you into a family feud.")
            ]
            return scenarios.randomElement()!
        case .familyEmergency:
            return (
                "\(actor) needs urgent help",
                "Your \(actorLabel.lowercased()), \(actor), needs help with a sudden bill and asks you directly.",
                "Help Them",
                "Say No",
                "\(actor) asked for urgent family help."
            )
        case .moneyRequest:
            return (
                "\(actor) asks for cash",
                "\(actor) says they are short on money and asks you for a loan.",
                "Give Cash",
                "Say No",
                "\(actor) asked to borrow money."
            )
        case .gangRecruitment, .jobOffer, .gangHeist:
            // Built directly in handleRelationshipEvents with a stranger
            // actor — never routed through this family/friend scenario bank.
            return ("", "", "", "", "")
        }
    }

    private func handleRelationshipEvents(_ character: inout Character, log: inout [LogEntry]) {
        guard character.stage != .infant else { return }
        handlePassiveRelationshipEvent(&character, log: &log)

        // Being in a gang comes with its own pressures — occasionally
        // they'll pull you into a much bigger job than a street robbery.
        if let gangName = character.gangName, !character.isInJail, pendingSocialEvent == nil, Double.random(in: 0...1) < 0.16 {
            pendingSocialEvent = SocialEvent(
                kind: .gangHeist,
                actorRef: .stranger,
                actorName: gangName,
                actorLabel: "Gang",
                actorGender: Bool.random() ? .male : .female,
                targetRef: nil,
                targetName: nil,
                amount: 0
            )
            log.append(LogEntry(text: "\(gangName) has been planning something big and wants you in.", isAlert: true))
            return
        }

        // A stranger with a job lead or a gang pitch — rarer than the usual
        // family/friend drama, and never from someone already in your life.
        if character.stage != .child, !character.isInJail, pendingSocialEvent == nil, Double.random(in: 0...1) < 0.14 {
            let region = CountryData.profile(for: character.country).region
            let gender: Gender = Bool.random() ? .male : .female
            let strangerName = "\(NameData.randomFirstName(for: gender, region: region)) \(NameData.randomLastName(region: region))"
            let offerGang = character.gangName == nil && Bool.random()
            if offerGang {
                pendingSocialEvent = SocialEvent(
                    kind: .gangRecruitment,
                    actorRef: .stranger,
                    actorName: strangerName,
                    actorLabel: "Recruiter",
                    actorGender: gender,
                    targetRef: nil,
                    targetName: nil,
                    amount: 0
                )
                log.append(LogEntry(text: "\(strangerName) has been talking to you about \"joining the family.\"", isAlert: true))
            } else {
                pendingSocialEvent = SocialEvent(
                    kind: .jobOffer,
                    actorRef: .stranger,
                    actorName: strangerName,
                    actorLabel: "Contact",
                    actorGender: gender,
                    targetRef: nil,
                    targetName: nil,
                    amount: 0
                )
                log.append(LogEntry(text: "\(strangerName) says they might have work for you.", isAlert: false))
            }
            return
        }

        guard pendingSocialEvent == nil, Double.random(in: 0...1) < 0.42 else { return }

        let familyPeople = character.family
            .filter(\.isAlive)
            .filter { !$0.isOwnChild }
            .map { (ref: PersonRef.family($0.id), name: $0.name, label: $0.relation.rawValue, isFamily: true, volatility: 10, gender: $0.gender) }
        let friendPeople = character.friends
            .map { (ref: PersonRef.friend($0.id), name: $0.name, label: "Friend", isFamily: false, volatility: $0.volatility, gender: $0.gender) }
        let people = familyPeople + friendPeople
        guard let actor = people.randomElement() else { return }

        let relationship = relationshipValue(character, ref: actor.ref)
        let roll = Double.random(in: 0...1)
        if character.stage == .child {
            let target = people.filter { $0.ref != actor.ref }.randomElement()
            let kind: SocialEventKind = roll < 0.72 ? .hangoutInvite : .coverStory
            let scenario = socialScenario(kind: kind, actor: actor.name, actorLabel: actor.label, target: target?.name, stage: character.stage)
            pendingSocialEvent = SocialEvent(
                kind: kind,
                actorRef: actor.ref,
                actorName: actor.name,
                actorLabel: actor.label,
                actorGender: actor.gender,
                targetRef: target?.ref,
                targetName: target?.name,
                amount: 0,
                customTitle: scenario.title,
                customMessage: scenario.message,
                customAcceptTitle: scenario.accept,
                customDeclineTitle: scenario.decline
            )
            log.append(LogEntry(text: scenario.log, isAlert: false))
            return
        }

        if actor.isFamily && roll < 0.25 {
            let amount = localized(Int.random(in: 20...90), for: character)
            let scenario = socialScenario(kind: .familyEmergency, actor: actor.name, actorLabel: actor.label, target: nil, stage: character.stage)
            pendingSocialEvent = SocialEvent(
                kind: .familyEmergency,
                actorRef: actor.ref,
                actorName: actor.name,
                actorLabel: actor.label,
                actorGender: actor.gender,
                targetRef: nil,
                targetName: nil,
                amount: amount,
                customTitle: scenario.title,
                customMessage: "\(scenario.message) They need $\(amount).",
                customAcceptTitle: "Give $\(amount)",
                customDeclineTitle: scenario.decline
            )
            log.append(LogEntry(text: scenario.log, isAlert: true))
        } else if roll < 0.40 {
            let amount = localized(Int.random(in: 10...55), for: character)
            let scenario = socialScenario(kind: .moneyRequest, actor: actor.name, actorLabel: actor.label, target: nil, stage: character.stage)
            pendingSocialEvent = SocialEvent(
                kind: .moneyRequest,
                actorRef: actor.ref,
                actorName: actor.name,
                actorLabel: actor.label,
                actorGender: actor.gender,
                targetRef: nil,
                targetName: nil,
                amount: amount,
                customTitle: scenario.title,
                customMessage: "\(scenario.message) They want $\(amount).",
                customAcceptTitle: "Give $\(amount)",
                customDeclineTitle: scenario.decline
            )
            log.append(LogEntry(text: "\(scenario.log) ($\(amount))", isAlert: relationship < 35))
        } else if !actor.isFamily && (roll < 0.62 || actor.volatility > 78) {
            let kind: SocialEventKind = actor.volatility > 58 && Double.random(in: 0...1) < 0.62 ? .riskyScheme : .hangoutInvite
            let scenario = socialScenario(kind: kind, actor: actor.name, actorLabel: actor.label, target: nil, stage: character.stage)
            pendingSocialEvent = SocialEvent(
                kind: kind,
                actorRef: actor.ref,
                actorName: actor.name,
                actorLabel: actor.label,
                actorGender: actor.gender,
                targetRef: nil,
                targetName: nil,
                amount: 0,
                customTitle: scenario.title,
                customMessage: scenario.message,
                customAcceptTitle: scenario.accept,
                customDeclineTitle: scenario.decline
            )
            log.append(LogEntry(text: scenario.log, isAlert: actor.volatility > 75))
        } else if roll < 0.78 {
            let possibleTargets = people.filter { $0.ref != actor.ref }
            let target = possibleTargets.randomElement()
            let scenario = socialScenario(kind: .coverStory, actor: actor.name, actorLabel: actor.label, target: target?.name, stage: character.stage)
            pendingSocialEvent = SocialEvent(
                kind: .coverStory,
                actorRef: actor.ref,
                actorName: actor.name,
                actorLabel: actor.label,
                actorGender: actor.gender,
                targetRef: target?.ref,
                targetName: target?.name,
                amount: 0,
                customTitle: scenario.title,
                customMessage: scenario.message,
                customAcceptTitle: scenario.accept,
                customDeclineTitle: scenario.decline
            )
            log.append(LogEntry(text: scenario.log, isAlert: true))
        } else if character.stage != .child {
            let possibleTargets = people.filter { $0.ref != actor.ref }
            let target = possibleTargets.randomElement()
            let scenario = socialScenario(kind: .fightBackup, actor: actor.name, actorLabel: actor.label, target: target?.name, stage: character.stage)
            pendingSocialEvent = SocialEvent(
                kind: .fightBackup,
                actorRef: actor.ref,
                actorName: actor.name,
                actorLabel: actor.label,
                actorGender: actor.gender,
                targetRef: target?.ref,
                targetName: target?.name,
                amount: 0,
                customTitle: scenario.title,
                customMessage: scenario.message,
                customAcceptTitle: scenario.accept,
                customDeclineTitle: scenario.decline
            )
            log.append(LogEntry(text: scenario.log, isAlert: true))
        }
    }

    private func handlePassiveRelationshipEvent(_ character: inout Character, log: inout [LogEntry]) {
        guard Double.random(in: 0...1) < 0.35 else { return }

        if let family = character.family.filter({ $0.isAlive && !$0.isOwnChild }).randomElement(),
           family.relationship >= 70,
           Double.random(in: 0...1) < 0.45 {
            let amount = localized(Int.random(in: 10...45), for: character)
            character.cash += amount
            log.append(LogEntry(text: "\(family.name) surprised you with $\(amount) because you've been close lately.", isAlert: false))
            return
        }

        if let friend = character.friends.randomElement(),
           friend.relationship >= 75,
           character.friends.count < 6,
           Double.random(in: 0...1) < 0.40 {
            let gender: Gender = Bool.random() ? .male : .female
            let region = CountryData.profile(for: character.country).region
            let name = "\(NameData.randomFirstName(for: gender, region: region)) \(NameData.randomLastName(region: region))"
            character.friends.append(Friend(name: name, gender: gender, relationship: Int.random(in: 35...60)))
            log.append(LogEntry(text: "\(friend.name) introduced you to \(name), and you became friends.", isAlert: false))
            return
        }

        if let friend = character.friends.randomElement(),
           friend.relationship < 35,
           Double.random(in: 0...1) < 0.55 {
            let loss = Int.random(in: 4...12)
            if let index = character.friends.firstIndex(where: { $0.id == friend.id }) {
                character.friends[index].adjustRelationship(-loss)
            }
            character.stats.adjust(happiness: -Int.random(in: 1...4))
            log.append(LogEntry(text: "\(friend.name) spread an ugly rumor about you. Relationship -\(loss).", isAlert: true))
            return
        }

        if let family = character.family.filter({ $0.isAlive && !$0.isOwnChild }).randomElement(),
           family.relationship < 40 {
            let loss = Int.random(in: 4...10)
            if let index = character.family.firstIndex(where: { $0.id == family.id }) {
                character.family[index].adjustRelationship(-loss)
            }
            log.append(LogEntry(text: "Tension with \(family.name) got worse after a family argument. Relationship -\(loss).", isAlert: true))
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
        guard character.isAlive else { return }
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
        // Vision correction isn't a medical condition that kills anyone — it
        // just means glasses are needed — so it never shows up as a cause.
        let conditionNames = character.conditions.compactMap { active -> String? in
            guard let condition = ConditionData.byID[active.conditionID], !condition.requiresGlasses else { return nil }
            return condition.name
        }
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
