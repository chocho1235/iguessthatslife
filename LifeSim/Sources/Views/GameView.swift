import SwiftUI
import SpriteKit
import UIKit

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showingShop = false
    @State private var showingBank = false
    @State private var showingDoctor = false
    @State private var showingCareer = false
    @State private var showingCrime = false
    @State private var showingMigration = false
    @State private var showingActivities = false
    @State private var jailFeedback: String?
    @State private var showingJailResult = false
    @State private var selectedPerson: PersonSelection?
    @State private var showAttackFlash = false
    @State private var familyFeedback: String?
    @State private var showingFamilyResult = false

    var character: Character { viewModel.character! }

    var body: some View {
        Group {
            ScrollView {
                VStack(spacing: 14) {
                    header
                    statsCard
                    eventLog
                    actionBar
                    if let partner = character.partner {
                        PartnerView(partner: partner, stage: character.stage, country: character.country) { selectedPerson = $0 }
                    }
                    familyActionsRow
                    FamilyView(family: character.family, country: character.country) { selectedPerson = $0 }
                    FriendsView(friends: character.friends, stage: character.stage, country: character.country) { selectedPerson = $0 }
                }
                .padding()
                .padding(.bottom, 90)
            }
            .overlay(alignment: .bottom) {
                ageUpButton
            }
        }
        .blur(radius: character.hasUncorrectedVision ? 3.5 : 0)
        .animation(.easeInOut, value: character.hasUncorrectedVision)
        .overlay {
            Color.red
                .opacity(showAttackFlash ? 0.45 : 0)
                .allowsHitTesting(false)
                .ignoresSafeArea()
                .animation(.easeOut(duration: 0.35), value: showAttackFlash)
        }
        .onChange(of: viewModel.attackTrigger) {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            showAttackFlash = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                showAttackFlash = false
            }
        }
        .overlay(alignment: .top) {
            if character.hasUncorrectedVision {
                Text("👓 Vision is blurry — try glasses from the Shop")
                    .font(.caption.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.yellow.opacity(0.9))
                    .clipShape(Capsule())
                    .padding(.top, 8)
                    .transition(.opacity)
            }
        }
        .sheet(isPresented: $showingShop) {
            ShopHubView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingBank) {
            BankHubView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingDoctor) {
            DoctorView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingCareer) {
            CareerView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingCrime) {
            CrimeView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingMigration) {
            MigrationMapView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingActivities) {
            ActivitiesView(viewModel: viewModel)
        }
        .sheet(item: $selectedPerson) { person in
            PersonDetailView(viewModel: viewModel, person: person)
        }
        .sheet(item: $viewModel.pendingSocialEvent) { event in
            SocialEventDecisionView(
                event: event,
                cash: character.cash,
                onAccept: {
                    withAnimation {
                        viewModel.resolveSocialEvent(accepted: true)
                    }
                },
                onDecline: {
                    withAnimation {
                        viewModel.resolveSocialEvent(accepted: false)
                    }
                }
            )
        }
        .sheet(item: $viewModel.pendingLegalTrouble) { trouble in
            LegalTroubleView(trouble: trouble, cash: character.cash) { hireLawyer in
                _ = viewModel.resolveLegalTrouble(hireLawyer: hireLawyer)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            AvatarView(seed: character.fullName, gender: character.gender, stage: character.stage, country: character.country, equipped: character.equippedAccessories, equippedOutfit: character.equippedOutfit, scars: character.scars)
                .frame(width: 78, height: 78)
                .background(Color(.tertiarySystemBackground))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 5) {
                Text(character.fullName)
                    .font(.title3.bold())
                    .lineLimit(1)
                Text("Age \(character.age) · \(character.country)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let gang = character.gangName {
                    Label(gang, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.red)
                        .lineLimit(1)
                } else if let job = character.job {
                    Label(job.title, systemImage: "briefcase.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.green)
                        .lineLimit(1)
                } else {
                    Label(lifeStageLabel, systemImage: "person.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text("$\(character.cash)")
                    .font(.title3.bold())
                    .monospacedDigit()
                Text(cashLabel)
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    @ViewBuilder
    private var actionBar: some View {
        if character.isInJail {
            jailActionBar
        } else {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                dashboardButton("Shop", icon: "bag.fill", color: .blue) {
                    showingShop = true
                }
                dashboardButton("Bank", icon: "building.columns.fill", color: .mint) {
                    showingBank = true
                }
                dashboardButton("Doctor", icon: "stethoscope", color: .red) {
                    showingDoctor = true
                }
                dashboardButton("Career", icon: "briefcase.fill", color: .green) {
                    showingCareer = true
                }
                dashboardButton("Crime", icon: "exclamationmark.triangle.fill", color: .red) {
                    showingCrime = true
                }
                dashboardButton("Migrate", icon: "airplane", color: .purple) {
                    showingMigration = true
                }
                dashboardButton("Activities", icon: "star.fill", color: .orange) {
                    showingActivities = true
                }
            }
        }
    }

    private var jailActionBar: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                Text("IN PRISON — \(character.jailYearsRemaining) YEAR\(character.jailYearsRemaining == 1 ? "" : "S") LEFT")
                    .font(.caption.bold())
                Spacer()
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.red.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                dashboardButton("Doctor", icon: "stethoscope", color: .red) {
                    showingDoctor = true
                }
                dashboardButton("Attempt Escape", icon: "figure.run", color: .orange) {
                    jailFeedback = viewModel.attemptEscape()
                    showingJailResult = true
                }
            }
        }
        .alert("Jailbreak", isPresented: $showingJailResult) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(jailFeedback ?? "")
        }
    }

    @ViewBuilder
    private var familyActionsRow: some View {
        if character.stage == .adult {
            HStack(spacing: 10) {
                Button {
                    familyFeedback = viewModel.tryForBaby()
                    showingFamilyResult = true
                } label: {
                    Label("Have a Baby", systemImage: "figure.and.child.holdinghands")
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.bordered)
                .tint(.pink)
                .disabled(viewModel.tryForBabyEligibilityMessage() != nil)

                Button {
                    familyFeedback = viewModel.adoptChild()
                    showingFamilyResult = true
                } label: {
                    Label("Adopt", systemImage: "person.badge.plus")
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.bordered)
                .tint(.purple)
                .disabled(viewModel.adoptChildEligibilityMessage() != nil)
            }
            .alert("Family", isPresented: $showingFamilyResult) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(familyFeedback ?? "")
            }
        }
    }

    private func dashboardButton(_ title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.headline)
                Text(title)
                    .font(.caption.bold())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.13))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.20), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stats")
                .font(.headline)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatBarView(label: "Health", value: character.stats.health, color: .red)
                StatBarView(label: "Happy", value: character.stats.happiness, color: .yellow)
                StatBarView(label: "Smarts", value: character.stats.smarts, color: .blue)
                StatBarView(label: "Looks", value: character.stats.looks, color: .purple)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var eventLog: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("This Year")
                    .font(.headline)
                Spacer()
                Text("Age \(character.age)")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            if viewModel.yearLog.isEmpty {
                Text("Nothing happened yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.yearLog) { entry in
                    Text("• \(entry.text)")
                        .font(.subheadline)
                        .foregroundStyle(entry.isAlert ? .red : .primary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var hasPendingDecision: Bool {
        viewModel.pendingSocialEvent != nil || viewModel.pendingLegalTrouble != nil
    }

    private var ageUpButton: some View {
        Button {
            withAnimation { viewModel.ageUp() }
        } label: {
            Text(hasPendingDecision ? "Answer First" : (character.isInJail ? "Serve Time (+1 year)" : "Age Up (+1 year)"))
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(hasPendingDecision ? Color.gray : (character.isInJail ? Color.red : Color.green))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(hasPendingDecision)
        .padding(.horizontal)
        .padding(.bottom, 20)
        .background(
            LinearGradient(colors: [.clear, Color(.systemBackground)], startPoint: .top, endPoint: .bottom)
                .frame(height: 110)
                .allowsHitTesting(false),
            alignment: .top
        )
    }

    private var lifeStageLabel: String {
        switch character.stage {
        case .infant: return "Infant"
        case .child: return "Child"
        case .teen: return "Teen"
        case .adult: return "Adult"
        case .senior: return "Senior"
        }
    }

    private var cashLabel: String {
        switch character.stage {
        case .infant, .child: return "Savings"
        case .teen: return "Cash"
        case .adult, .senior: return "Balance"
        }
    }
}

#Preview {
    let vm = GameViewModel()
    vm.startNewLife()
    return GameView(viewModel: vm)
}

private struct CrimeView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var feedback = "Choose carefully. Crime can leave scars, records, enemies, or worse."
    @State private var showingResult = false
    @State private var showingRobberyGame = false
    @State private var robberySetup = RobberySetup(isMafiaBoss: false, difficulty: .standard, scenario: .pickpocket)

    private var character: Character? { viewModel.character }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    statusPanel
                    feedbackPanel
                    actionSection
                }
                .padding()
            }
            .navigationTitle("Crime")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Crime Result", isPresented: $showingResult) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(feedback)
            }
            .fullScreenCover(isPresented: $showingRobberyGame) {
                RobberyGameView(
                    playerIdentity: AvatarVisualIdentity(
                        seed: character?.fullName ?? "Player",
                        stage: character?.stage ?? .adult,
                        region: character.map { CountryData.profile(for: $0.country).region } ?? .angloWestern
                    ),
                    playerAccessories: character?.equippedAccessories ?? [],
                    setup: robberySetup
                ) { success, loot in
                    if robberySetup.isMafiaBoss && !success {
                        feedback = viewModel.resolveMafiaRobberyCaught()
                    } else {
                        feedback = viewModel.resolveRobberyMiniGame(
                            success: success,
                            lootValue: robberySetup.scenario == .houseBurglary ? loot : nil,
                            scenario: robberySetup.scenario
                        )
                    }
                    showingRobberyGame = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        showingResult = true
                    }
                }
            }
            .sheet(item: $viewModel.pendingLegalTrouble) { trouble in
                LegalTroubleView(trouble: trouble, cash: character?.cash ?? 0) { hireLawyer in
                    feedback = viewModel.resolveLegalTrouble(hireLawyer: hireLawyer)
                    showingResult = true
                }
            }
        }
    }

    private var feedbackPanel: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "text.bubble.fill")
                .foregroundStyle(.red)
            Text(feedback)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var statusPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Status")
                .font(.headline)

            if let character {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    crimeStatus("Gang", value: character.gangName ?? "None", icon: "person.3.fill", color: character.gangName == nil ? .secondary : .red)
                    crimeStatus("Weapon", value: character.weaponName ?? "None", icon: "shield.lefthalf.filled", color: character.weaponName == nil ? .secondary : .orange)
                    crimeStatus("Record", value: "\(character.criminalRecord)", icon: "doc.text.fill", color: character.criminalRecord == 0 ? .secondary : .purple)
                    crimeStatus("Cash", value: "$\(character.cash)", icon: "dollarsign.circle.fill", color: .green)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var actionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Actions")
                .font(.headline)
            Text("Looking for a weapon? Visit the Weapons shop.")
                .font(.caption)
                .foregroundStyle(.secondary)

            crimeButton("Join Gang", requirement: "Age 13+", icon: "person.3.fill", tint: .red) {
                perform(viewModel.joinGang)
            }
            crimeButton("Leave Gang", requirement: "Must belong to a gang", icon: "figure.walk", tint: .indigo) {
                perform(viewModel.leaveGang)
            }
            crimeButton("Rob Someone", requirement: "Age 13+", icon: "bag.fill.badge.minus", tint: .purple) {
                if let message = viewModel.robberyEligibilityMessage() {
                    feedback = message
                    showingResult = true
                } else {
                    robberySetup = viewModel.prepareRobbery()
                    showingRobberyGame = true
                }
            }
            crimeButton("Attempt Murder", requirement: "Age 16+ · needs a target", icon: "bolt.fill", tint: .red) {
                perform(viewModel.attemptMurder)
            }
            crimeButton("Hire Hitman", requirement: "Age 18+ · $900", icon: "phone.fill", tint: .black) {
                perform(viewModel.hireHitman)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func crimeStatus(_ title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(color.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func crimeButton(_ title: String, requirement: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 26)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.bold())
                    Text(requirement)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(tint.opacity(0.12))
            .foregroundStyle(tint)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private func perform(_ action: () -> String) {
        feedback = action()
        showingResult = true
    }
}

private struct RobberyGameView: View {
    @Environment(\.dismiss) private var dismiss
    let onComplete: (Bool, Int) -> Void
    let difficultyLabel: String
    let scenario: RobberyScenario
    @State private var scene: RobberyScene

    init(playerIdentity: AvatarVisualIdentity, playerAccessories: [Accessory], setup: RobberySetup, onComplete: @escaping (Bool, Int) -> Void) {
        self.onComplete = onComplete
        self.difficultyLabel = setup.difficulty.label
        self.scenario = setup.scenario
        _scene = State(
            initialValue: RobberyScene(
                size: CGSize(width: 390, height: 844),
                playerIdentity: playerIdentity,
                playerAccessories: playerAccessories,
                difficulty: setup.difficulty,
                scenario: setup.scenario
            )
        )
    }

    var body: some View {
        ZStack {
            SpriteView(scene: scene, options: [.allowsTransparency])
                .ignoresSafeArea()

            VStack(spacing: 14) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.headline.bold())
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text(scenario == .houseBurglary ? "HOUSE BURGLARY" : "PICKPOCKET")
                            .font(.headline.bold())
                        Text(scenario == .houseBurglary ? "GRAB LOOT · REACH THE EXIT" : "TAKE THE WALLET · REACH THE EXIT")
                            .font(.caption2.bold())
                            .foregroundStyle(.secondary)
                        Text(difficultyLabel.uppercased())
                            .font(.caption2.bold())
                            .foregroundStyle(.orange)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    Spacer()

                    Image(systemName: "hand.draw.fill")
                        .font(.headline)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .padding(.horizontal)
                .padding(.top, 8)

                Spacer()

                if scenario == .houseBurglary {
                    HStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.fill")
                            .foregroundStyle(.blue)
                        Text("YOU")
                        Image(systemName: "timer")
                            .foregroundStyle(.orange)
                        Text("HOMEOWNER RETURNING SOON")
                    }
                    .font(.caption2.bold())
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.bottom, 22)
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.fill")
                            .foregroundStyle(.blue)
                        Text("YOU")
                        Image(systemName: "person.crop.circle")
                            .foregroundStyle(.orange)
                        Text("TARGET")
                        Image(systemName: "eye.slash.fill")
                        Text("STAY UNSEEN")
                    }
                    .font(.caption2.bold())
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.bottom, 22)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            scene.scaleMode = .resizeFill
            scene.resultHandler = onComplete
        }
    }
}

private final class RobberyScene: SKScene {
    /// (success, loot value collected — only meaningful for house burglaries)
    var resultHandler: ((Bool, Int) -> Void)?

    private let player = SKNode()
    private let target = SKNode()
    private let wallet = SKShapeNode(rectOf: CGSize(width: 18, height: 12), cornerRadius: 3)
    private let exitZone = SKShapeNode(rectOf: CGSize(width: 74, height: 42), cornerRadius: 8)
    private let visionCone = SKShapeNode()
    private let statusLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let riskBarBackground = SKShapeNode(rectOf: CGSize(width: 220, height: 14), cornerRadius: 7)
    private let riskBarFill = SKShapeNode(rectOf: CGSize(width: 216, height: 10), cornerRadius: 5)
    private var desiredPlayerPosition: CGPoint?
    private var targetDirection: CGFloat = 1
    private var hasWallet = false
    private var gameEnded = false
    private var elapsed: TimeInterval = 0
    private var lastUpdate: TimeInterval = 0
    private var obstacleFrames: [CGRect] = []
    private let playerIdentity: AvatarVisualIdentity
    private let playerAccessories: [Accessory]
    private let npcSeed = UUID().uuidString
    private let difficulty: RobberyDifficulty
    private let scenario: RobberyScenario
    private var lootItems: [(node: SKShapeNode, value: Int)] = []
    private var collectedLoot = 0
    private var homeownerDuration: Double { scenario.baseRiskDuration * difficulty.homeownerPatience }

    init(size: CGSize, playerIdentity: AvatarVisualIdentity, playerAccessories: [Accessory], difficulty: RobberyDifficulty, scenario: RobberyScenario) {
        self.playerIdentity = playerIdentity
        self.playerAccessories = playerAccessories
        self.difficulty = difficulty
        self.scenario = scenario
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        playerIdentity = AvatarVisualIdentity(seed: "Player", stage: .adult, region: .angloWestern)
        playerAccessories = []
        difficulty = .standard
        scenario = .pickpocket
        super.init(coder: aDecoder)
    }

    override func didMove(to view: SKView) {
        backgroundColor = scenario == .houseBurglary
            ? UIColor(red: 0.085, green: 0.065, blue: 0.05, alpha: 1)
            : UIColor(red: 0.055, green: 0.075, blue: 0.105, alpha: 1)
        anchorPoint = .zero

        drawFloor()
        configureExit()
        configurePlayer()
        configureStatus()

        switch scenario {
        case .pickpocket:
            configureTarget()
            updateWalletPosition()
            updateVisionCone()
        case .houseBurglary:
            scatterLoot()
            configureRiskMeter()
        }
    }

    private func drawFloor() {
        let isHouse = scenario == .houseBurglary
        let tile: CGFloat = 52
        var x: CGFloat = 0
        var column = 0
        while x < size.width + tile {
            var y: CGFloat = 0
            var row = 0
            while y < size.height + tile {
                let square = SKShapeNode(rect: CGRect(x: x, y: y, width: tile, height: tile))
                if isHouse {
                    square.fillColor = (column + row).isMultiple(of: 2)
                        ? UIColor(red: 0.26, green: 0.17, blue: 0.11, alpha: 1)
                        : UIColor(red: 0.30, green: 0.20, blue: 0.13, alpha: 1)
                } else {
                    square.fillColor = (column + row).isMultiple(of: 2)
                        ? UIColor(white: 0.115, alpha: 1)
                        : UIColor(white: 0.14, alpha: 1)
                }
                square.strokeColor = UIColor.white.withAlphaComponent(0.025)
                square.zPosition = -10
                addChild(square)
                y += tile
                row += 1
            }
            x += tile
            column += 1
        }

        let furniturePositions = [CGPoint(x: 75, y: size.height * 0.43), CGPoint(x: size.width - 70, y: size.height * 0.72)]
        for position in furniturePositions {
            let obstacle = SKShapeNode(rectOf: CGSize(width: 68, height: 68), cornerRadius: 10)
            obstacle.position = position
            obstacle.fillColor = isHouse
                ? UIColor(red: 0.42, green: 0.28, blue: 0.16, alpha: 1)
                : UIColor(red: 0.20, green: 0.23, blue: 0.28, alpha: 1)
            obstacle.strokeColor = UIColor.white.withAlphaComponent(0.12)
            obstacle.lineWidth = 2
            obstacle.zPosition = -1
            addChild(obstacle)
            obstacleFrames.append(obstacle.frame.insetBy(dx: -15, dy: -15))
        }
    }

    private func configureExit() {
        exitZone.position = CGPoint(x: 58, y: 80)
        exitZone.fillColor = UIColor.systemGreen.withAlphaComponent(0.28)
        exitZone.strokeColor = UIColor.systemGreen
        exitZone.lineWidth = 3
        exitZone.glowWidth = 4
        addChild(exitZone)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "EXIT"
        label.fontSize = 13
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        exitZone.addChild(label)
    }

    private func configurePlayer() {
        player.position = CGPoint(x: size.width - 58, y: 128)
        player.zPosition = 8
        player.addChild(makeTopDownAvatar(identity: playerIdentity, accessories: playerAccessories, isPlayer: true))
        addChild(player)

        let arrow = SKLabelNode(fontNamed: "AvenirNext-Bold")
        arrow.text = "YOU"
        arrow.fontSize = 10
        arrow.fontColor = .white
        arrow.position = CGPoint(x: 0, y: 30)
        player.addChild(arrow)
    }

    private func configureTarget() {
        target.position = CGPoint(x: size.width * 0.42, y: size.height * 0.61)
        target.zPosition = 6
        target.addChild(
            makeTopDownAvatar(
                identity: AvatarVisualIdentity(seed: npcSeed, stage: .adult, region: .angloWestern),
                accessories: [],
                isPlayer: false
            )
        )
        addChild(target)

        target.xScale = targetDirection
    }

    private func scatterLoot() {
        let spots = [
            CGPoint(x: size.width * 0.30, y: size.height * 0.68),
            CGPoint(x: size.width * 0.62, y: size.height * 0.58),
            CGPoint(x: size.width * 0.22, y: size.height * 0.40),
            CGPoint(x: size.width * 0.75, y: size.height * 0.33),
            CGPoint(x: size.width * 0.50, y: size.height * 0.78),
        ]
        for spot in spots {
            let isJewelry = Bool.random()
            let node: SKShapeNode
            let value: Int
            if isJewelry {
                node = SKShapeNode(circleOfRadius: 11)
                node.fillColor = .systemYellow
                node.strokeColor = .white
                node.lineWidth = 1.5
                node.glowWidth = 3
                value = Int.random(in: 60...220)
            } else {
                node = SKShapeNode(rectOf: CGSize(width: 24, height: 15), cornerRadius: 3)
                node.fillColor = .systemGreen
                node.strokeColor = .white
                node.lineWidth = 1.5
                value = Int.random(in: 40...160)
            }
            node.position = spot
            node.zPosition = 5
            addChild(node)
            lootItems.append((node: node, value: value))
        }
    }

    private func configureRiskMeter() {
        riskBarBackground.position = CGPoint(x: size.width / 2, y: size.height - 110)
        riskBarBackground.fillColor = UIColor.black.withAlphaComponent(0.4)
        riskBarBackground.strokeColor = UIColor.white.withAlphaComponent(0.3)
        riskBarBackground.zPosition = 19
        addChild(riskBarBackground)

        riskBarFill.fillColor = .systemGreen
        riskBarFill.strokeColor = .clear
        riskBarFill.zPosition = 20
        addChild(riskBarFill)
        updateRiskMeter()
    }

    private func updateRiskMeter() {
        guard scenario == .houseBurglary, homeownerDuration > 0 else { return }
        let progress = min(1, elapsed / homeownerDuration)
        let maxWidth: CGFloat = 212
        let width = max(4, maxWidth * CGFloat(progress))
        let barRect = CGRect(x: -maxWidth / 2, y: -5, width: width, height: 10)
        riskBarFill.path = CGPath(roundedRect: barRect, cornerWidth: 5, cornerHeight: 5, transform: nil)
        riskBarFill.position = riskBarBackground.position
        riskBarFill.fillColor = progress < 0.6 ? .systemGreen : (progress < 0.85 ? .systemOrange : .systemRed)
    }

    private func makeTopDownAvatar(identity: AvatarVisualIdentity, accessories: [Accessory], isPlayer: Bool) -> SKNode {
        let avatar = SKNode()
        avatar.name = "avatar"
        let skin = UIColor(identity.skinTone)
        let hair = UIColor(identity.hairColor)
        let outfit = UIColor(identity.outfitColor)

        let shadow = SKShapeNode(ellipseOf: CGSize(width: 50, height: 38))
        shadow.position = CGPoint(x: -6, y: -2)
        shadow.fillColor = UIColor.black.withAlphaComponent(0.30)
        shadow.strokeColor = .clear
        shadow.zPosition = -3
        avatar.addChild(shadow)

        let shoulders = SKShapeNode(ellipseOf: CGSize(width: 35, height: 45))
        shoulders.position = CGPoint(x: -10, y: 0)
        shoulders.fillColor = outfit
        shoulders.strokeColor = isPlayer ? .white : outfit.withAlphaComponent(0.85)
        shoulders.lineWidth = isPlayer ? 3 : 2
        shoulders.name = "outfit"
        avatar.addChild(shoulders)

        for y in [-15.0, 15.0] {
            let hand = SKShapeNode(circleOfRadius: 4.5)
            hand.position = CGPoint(x: -3, y: y)
            hand.fillColor = skin
            hand.strokeColor = .clear
            avatar.addChild(hand)
        }

        let hairCap = SKShapeNode(circleOfRadius: 17)
        hairCap.position = CGPoint(x: 2, y: 0)
        hairCap.fillColor = hair
        hairCap.strokeColor = .clear
        avatar.addChild(hairCap)

        let face = SKShapeNode(circleOfRadius: 13.5)
        face.position = CGPoint(x: 7, y: 0)
        face.fillColor = skin
        face.strokeColor = UIColor.white.withAlphaComponent(0.65)
        face.lineWidth = 1.5
        avatar.addChild(face)

        let hairPatch = SKShapeNode(ellipseOf: CGSize(width: 18, height: 23))
        hairPatch.position = CGPoint(x: 0, y: 0)
        hairPatch.fillColor = hair
        hairPatch.strokeColor = hair.withAlphaComponent(0.8)
        hairPatch.zPosition = 2
        avatar.addChild(hairPatch)

        let highlight = SKShapeNode(ellipseOf: CGSize(width: 6, height: 12))
        highlight.position = CGPoint(x: -2, y: 4)
        highlight.fillColor = UIColor.white.withAlphaComponent(0.16)
        highlight.strokeColor = .clear
        highlight.zPosition = 3
        avatar.addChild(highlight)

        let nose = SKShapeNode()
        let nosePath = CGMutablePath()
        nosePath.move(to: CGPoint(x: 19, y: 0))
        nosePath.addLine(to: CGPoint(x: 14, y: 4))
        nosePath.addLine(to: CGPoint(x: 14, y: -4))
        nosePath.closeSubpath()
        nose.path = nosePath
        nose.fillColor = skin
        nose.strokeColor = UIColor.black.withAlphaComponent(0.16)
        nose.lineWidth = 1
        nose.zPosition = 4
        avatar.addChild(nose)

        drawTopDownAccessories(accessories, on: avatar)

        if isPlayer {
            let ring = SKShapeNode(circleOfRadius: 23)
            ring.strokeColor = .systemBlue
            ring.lineWidth = 3
            ring.glowWidth = 4
            ring.fillColor = .clear
            ring.zPosition = -1
            avatar.addChild(ring)
        }
        return avatar
    }

    private func drawTopDownAccessories(_ accessories: [Accessory], on avatar: SKNode) {
        if let headwear = accessories.first(where: { $0.slot == .head }) {
            let color = UIColor(headwear.color)
            switch headwear.id {
            case "cap":
                let cap = SKShapeNode(ellipseOf: CGSize(width: 33, height: 31))
                cap.position = CGPoint(x: 1, y: 0)
                cap.fillColor = color
                cap.strokeColor = UIColor.white.withAlphaComponent(0.25)
                cap.zPosition = 5
                avatar.addChild(cap)

                let bill = SKShapeNode(ellipseOf: CGSize(width: 13, height: 21))
                bill.position = CGPoint(x: 18, y: 0)
                bill.fillColor = color.withAlphaComponent(0.85)
                bill.strokeColor = .clear
                bill.zPosition = 4
                avatar.addChild(bill)
            case "beanie":
                let beanie = SKShapeNode(circleOfRadius: 17)
                beanie.position = CGPoint(x: 2, y: 0)
                beanie.fillColor = color
                beanie.strokeColor = UIColor.white.withAlphaComponent(0.30)
                beanie.lineWidth = 2
                beanie.zPosition = 5
                avatar.addChild(beanie)

                let pom = SKShapeNode(circleOfRadius: 4)
                pom.position = CGPoint(x: -12, y: 0)
                pom.fillColor = .white
                pom.strokeColor = .clear
                pom.zPosition = 6
                avatar.addChild(pom)
            case "tophat":
                let brim = SKShapeNode(ellipseOf: CGSize(width: 38, height: 31))
                brim.position = CGPoint(x: 1, y: 0)
                brim.fillColor = .black
                brim.strokeColor = UIColor.white.withAlphaComponent(0.30)
                brim.zPosition = 5
                avatar.addChild(brim)

                let crown = SKShapeNode(ellipseOf: CGSize(width: 25, height: 22))
                crown.position = CGPoint(x: 2, y: 0)
                crown.fillColor = UIColor(white: 0.08, alpha: 1)
                crown.strokeColor = .systemRed
                crown.lineWidth = 2
                crown.zPosition = 6
                avatar.addChild(crown)
            default:
                break
            }
        }

        guard let facewear = accessories.first(where: { $0.slot == .face }) else { return }
        let frameColor = UIColor(facewear.color)
        if facewear.id == "eyepatch" {
            let patch = SKShapeNode(circleOfRadius: 4)
            patch.position = CGPoint(x: 14, y: 6)
            patch.fillColor = .black
            patch.strokeColor = .clear
            patch.zPosition = 7
            avatar.addChild(patch)
        } else {
            for y in [-6.0, 6.0] {
                let lens = SKShapeNode(ellipseOf: CGSize(width: 7, height: 8))
                lens.position = CGPoint(x: 14, y: y)
                lens.fillColor = facewear.id == "sunglasses" ? UIColor.black.withAlphaComponent(0.80) : .clear
                lens.strokeColor = frameColor
                lens.lineWidth = 1.5
                lens.zPosition = 7
                avatar.addChild(lens)
            }
        }
    }

    private func configureStatus() {
        statusLabel.text = scenario == .houseBurglary ? "GRAB THE LOOT" : "GET BEHIND THE TARGET"
        statusLabel.fontSize = 15
        statusLabel.fontColor = .white
        statusLabel.position = CGPoint(x: size.width / 2, y: size.height - 155)
        statusLabel.zPosition = 20
        addChild(statusLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        desiredPlayerPosition = touches.first?.location(in: self)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        desiredPlayerPosition = touches.first?.location(in: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        desiredPlayerPosition = touches.first?.location(in: self)
    }

    override func update(_ currentTime: TimeInterval) {
        guard !gameEnded else { return }
        let delta = lastUpdate == 0 ? 0 : min(currentTime - lastUpdate, 1.0 / 30.0)
        lastUpdate = currentTime
        elapsed += delta

        movePlayer(delta: delta)

        switch scenario {
        case .pickpocket:
            patrolTarget(delta: delta)
            updateWalletPosition()
            updateVisionCone()

            if elapsed > difficulty.graceSeconds, isPlayerVisible() {
                finish(success: false)
                return
            }

            if !hasWallet, distance(player.position, wallet.position) < 27 {
                hasWallet = true
                wallet.removeFromParent()
                statusLabel.text = "WALLET TAKEN - REACH THE EXIT"
                (player.childNode(withName: "//outfit") as? SKShapeNode)?.fillColor = .systemGreen
            }

            if hasWallet, distance(player.position, exitZone.position) < 46 {
                finish(success: true)
            }

        case .houseBurglary:
            updateRiskMeter()

            for item in lootItems where item.node.parent != nil {
                if distance(player.position, item.node.position) < 26 {
                    item.node.removeFromParent()
                    collectedLoot += item.value
                    statusLabel.text = "COLLECTED $\(collectedLoot) - KEEP GOING OR LEAVE"
                }
            }

            if elapsed > homeownerDuration {
                finish(success: false)
                return
            }

            if distance(player.position, exitZone.position) < 46 {
                finish(success: true)
            }
        }
    }

    private func movePlayer(delta: TimeInterval) {
        guard let destination = desiredPlayerPosition else { return }
        let dx = destination.x - player.position.x
        let dy = destination.y - player.position.y
        let length = max(sqrt(dx * dx + dy * dy), 0.001)
        if length < 4 { return }
        let previousPosition = player.position
        let step = min(CGFloat(delta) * 185, length)
        player.position.x += dx / length * step
        player.position.y += dy / length * step
        player.position.x = min(max(player.position.x, 20), size.width - 20)
        player.position.y = min(max(player.position.y, 54), size.height - 100)
        let playerBounds = CGRect(x: player.position.x - 18, y: player.position.y - 18, width: 36, height: 36)
        if obstacleFrames.contains(where: { playerBounds.intersects($0) }) {
            player.position = previousPosition
        } else {
            player.childNode(withName: "avatar")?.zRotation = atan2(dy, dx)
        }
    }

    private func patrolTarget(delta: TimeInterval) {
        target.position.x += targetDirection * CGFloat(delta) * difficulty.patrolSpeed
        if target.position.x > size.width - 74 {
            targetDirection = -1
        } else if target.position.x < 74 {
            targetDirection = 1
        }
        target.xScale = targetDirection
    }

    private func updateWalletPosition() {
        guard !hasWallet else { return }
        if wallet.parent == nil {
            wallet.fillColor = .systemYellow
            wallet.strokeColor = .white
            wallet.lineWidth = 2
            wallet.zPosition = 7
            addChild(wallet)
        }
        wallet.position = CGPoint(x: target.position.x - targetDirection * 32, y: target.position.y)
    }

    private func updateVisionCone() {
        let coneLength: CGFloat = difficulty.coneLength
        let halfWidth: CGFloat = difficulty.coneHalfWidth
        let path = CGMutablePath()
        path.move(to: target.position)
        path.addLine(to: CGPoint(x: target.position.x + targetDirection * coneLength, y: target.position.y + halfWidth))
        path.addLine(to: CGPoint(x: target.position.x + targetDirection * coneLength, y: target.position.y - halfWidth))
        path.closeSubpath()
        visionCone.path = path
        visionCone.fillColor = UIColor.systemYellow.withAlphaComponent(0.16)
        visionCone.strokeColor = UIColor.systemYellow.withAlphaComponent(0.28)
        visionCone.lineWidth = 1
        visionCone.zPosition = 1
        if visionCone.parent == nil { addChild(visionCone) }
    }

    private func isPlayerVisible() -> Bool {
        let dx = player.position.x - target.position.x
        let dy = player.position.y - target.position.y
        let length = sqrt(dx * dx + dy * dy)
        guard length < difficulty.coneLength, length > 0 else { return false }
        let forwardAmount = (dx / length) * targetDirection
        return forwardAmount > 0.82
    }

    private func distance(_ first: CGPoint, _ second: CGPoint) -> CGFloat {
        let dx = first.x - second.x
        let dy = first.y - second.y
        return sqrt(dx * dx + dy * dy)
    }

    private func finish(success: Bool) {
        guard !gameEnded else { return }
        gameEnded = true
        if scenario == .houseBurglary {
            statusLabel.text = success ? "CLEAN GETAWAY - $\(collectedLoot)" : "THE HOMEOWNER IS HOME"
        } else {
            statusLabel.text = success ? "CLEAN GETAWAY" : "SPOTTED"
        }
        statusLabel.fontColor = success ? .systemGreen : .systemRed
        let loot = collectedLoot
        run(.sequence([.wait(forDuration: 0.65), .run { [weak self] in
            self?.resultHandler?(success, loot)
        }]))
    }
}

private struct SocialEventDecisionView: View {
    let event: SocialEvent
    let cash: Int
    let onAccept: () -> Void
    let onDecline: () -> Void
    @Environment(\.dismiss) private var dismiss

    private var canAffordAccept: Bool {
        switch event.kind {
        case .moneyRequest, .familyEmergency:
            return cash >= event.amount
        case .fightBackup, .hangoutInvite, .riskyScheme, .coverStory, .gangRecruitment, .jobOffer, .gangHeist:
            return true
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            ZStack(alignment: .bottomTrailing) {
                AvatarView(seed: event.actorName, gender: event.actorGender, stage: .adult)
                    .frame(width: 92, height: 92)
                    .clipShape(Circle())
                    .overlay { Circle().stroke(iconColor, lineWidth: 3) }

                Image(systemName: iconName)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(iconColor)
                    .clipShape(Circle())
                    .overlay { Circle().stroke(.white, lineWidth: 2) }
            }

            VStack(spacing: 8) {
                Text(event.title)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                Text(event.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                Button {
                    onAccept()
                    dismiss()
                } label: {
                    Label(event.acceptTitle, systemImage: acceptIconName)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(iconColor)
                .disabled(!canAffordAccept)

                Button {
                    onDecline()
                    dismiss()
                } label: {
                    Text(event.declineTitle)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.bordered)
            }

            if !canAffordAccept {
                Text("You only have $\(cash).")
                    .font(.caption.bold())
                    .foregroundStyle(.red)
            }
        }
        .padding(28)
        .presentationDetents([.medium])
    }

    private var iconName: String {
        switch event.kind {
        case .moneyRequest: return "dollarsign.circle.fill"
        case .fightBackup: return "bolt.shield.fill"
        case .familyEmergency: return "exclamationmark.triangle.fill"
        case .hangoutInvite: return "figure.2"
        case .riskyScheme: return "flame.fill"
        case .coverStory: return "theatermasks.fill"
        case .gangRecruitment: return "person.3.fill"
        case .jobOffer: return "briefcase.fill"
        case .gangHeist: return "banknote.fill"
        }
    }

    private var acceptIconName: String {
        switch event.kind {
        case .moneyRequest, .familyEmergency: return "hand.raised.fill"
        case .fightBackup: return "figure.boxing"
        case .hangoutInvite: return "figure.walk"
        case .riskyScheme: return "bolt.fill"
        case .coverStory: return "bubble.left.and.bubble.right.fill"
        case .gangRecruitment: return "person.3.fill"
        case .jobOffer: return "briefcase.fill"
        case .gangHeist: return "banknote.fill"
        }
    }

    private var iconColor: Color {
        switch event.kind {
        case .moneyRequest: return .green
        case .fightBackup: return .red
        case .familyEmergency: return .orange
        case .hangoutInvite: return .blue
        case .riskyScheme: return .purple
        case .coverStory: return .indigo
        case .gangRecruitment: return .red
        case .jobOffer: return .green
        case .gangHeist: return .red
        }
    }
}
