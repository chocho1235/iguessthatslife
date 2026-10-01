import Foundation

/// Broad cultural/ethnic grouping used to pick names and a realistic skin
/// tone range for a character based on their country of birth. Real-world
/// populations are diverse within every country, so each region allows a
/// spread of tones rather than a single fixed one — but the spread is
/// weighted toward what's actually common there.
enum CultureRegion {
    case angloWestern
    case latinEurope
    case germanicNordic
    case slavicEastEurope
    case eastAsia
    case southAsia
    case southeastAsia
    case middleEastNorthAfrica
    case subSaharanAfrica
    case latinAmerica

    /// Indices into `AvatarPalette.skinTones` (0 = fairest, 10 = deepest),
    /// repeated to weight toward the most common tones for the region while
    /// still leaving room for natural variation.
    var skinToneIndices: [Int] {
        switch self {
        case .angloWestern: return [0, 1, 1, 2, 2, 3, 4]
        case .latinEurope: return [0, 1, 2, 2, 3]
        case .germanicNordic: return [0, 0, 1, 1, 2]
        case .slavicEastEurope: return [0, 0, 1, 1, 2]
        case .eastAsia: return [1, 1, 2, 2, 3]
        case .southAsia: return [4, 5, 5, 6, 7]
        case .southeastAsia: return [3, 3, 4, 5, 6]
        case .middleEastNorthAfrica: return [3, 4, 4, 5, 6]
        case .subSaharanAfrica: return [6, 7, 7, 8, 8, 9, 10]
        case .latinAmerica: return [2, 3, 4, 4, 5, 6]
        }
    }
}
