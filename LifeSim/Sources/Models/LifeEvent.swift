import Foundation

struct LifeEvent: Identifiable {
    let id = UUID()
    let stages: Set<LifeStage>
    let text: (Character) -> String
    let weight: Int
    let healthDelta: Int
    let happinessDelta: Int
    let smartsDelta: Int
    let looksDelta: Int
    let relationshipDelta: Int
    let cashDelta: Int
    let fatal: Bool
    let grantsConditionID: String?

    init(
        stages: Set<LifeStage>,
        weight: Int = 10,
        health: Int = 0,
        happiness: Int = 0,
        smarts: Int = 0,
        looks: Int = 0,
        relationship: Int = 0,
        cash: Int = 0,
        fatal: Bool = false,
        grantsCondition: String? = nil,
        text: @escaping (Character) -> String
    ) {
        self.stages = stages
        self.weight = weight
        self.healthDelta = health
        self.happinessDelta = happiness
        self.smartsDelta = smarts
        self.looksDelta = looks
        self.relationshipDelta = relationship
        self.cashDelta = cash
        self.fatal = fatal
        self.grantsConditionID = grantsCondition
        self.text = text
    }
}
