import Foundation

enum AgeGroup: String, CaseIterable, Codable, CustomStringConvertible, Comparable {
    case preschoolers = "preschoolers"
    case littleKids = "littleKids"
    case bigKids = "bigKids"
    case tweens = "tweens"
    
    var emoji: String {
        switch self {
        case .preschoolers: return "🧸"
        case .littleKids: return "🎨"
        case .bigKids: return "🚀"
        case .tweens: return "🎭"
        }
    }
    
    var ageRange: String {
        switch self {
        case .preschoolers: return "2-4"
        case .littleKids: return "5-7"
        case .bigKids: return "8-9"
        case .tweens: return "10-12"
        }
    }
    
    var description: String {
        switch self {
        case .preschoolers: return "\(emoji) Preschoolers (\(ageRange))"
        case .littleKids: return "\(emoji) Little Kids (\(ageRange))"
        case .bigKids: return "\(emoji) Big Kids (\(ageRange))"
        case .tweens: return "\(emoji) Tweens (\(ageRange))"
        }
    }
    
    // MARK: - Comparable Implementation
    
    public static func < (lhs: AgeGroup, rhs: AgeGroup) -> Bool {
        let order: [AgeGroup] = [.preschoolers, .littleKids, .bigKids, .tweens]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }
}
