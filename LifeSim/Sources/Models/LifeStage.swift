import Foundation

enum LifeStage {
    case infant
    case child
    case teen
    case adult
    case senior

    static func forAge(_ age: Int) -> LifeStage {
        switch age {
        case 0...2: return .infant
        case 3...12: return .child
        case 13...17: return .teen
        case 18...64: return .adult
        default: return .senior
        }
    }
}
