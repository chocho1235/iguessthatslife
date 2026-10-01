import Foundation

struct PersonSelection: Identifiable {
    let ref: PersonRef
    let name: String
    let gender: Gender
    let stage: LifeStage
    let isAlive: Bool
    let relationship: Int
    let label: String
    var country: String? = nil

    var id: PersonRef { ref }
}
