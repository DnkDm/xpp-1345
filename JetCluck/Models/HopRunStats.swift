import Foundation

struct HopRunStats {
    let height: Int
    let coins: Int
    let clouds: Int
    let cans: Int
    let outcome: HopOutcome
}

enum HopOutcome {
    case fell
    case crashed

    var title: String {
        switch self {
        case .fell: "You Fell"
        case .crashed: "Game Over"
        }
    }
}

struct HopRunSnapshot {
    var height = 0
    var coins = 0
    /// How much of the jet boost is left, 0...1. Nil while it is not running.
    var boost: Double?
}
