import Foundation

enum PowerUp: String, CaseIterable, Identifiable, Codable {
    case shield
    case magnet
    case doubleCoins

    var id: String { rawValue }

    var title: String {
        switch self {
        case .shield: "Shield"
        case .magnet: "Magnet"
        case .doubleCoins: "Double Coins"
        }
    }

    /// Zero means the pickup is a charge that lasts until it is spent.
    var duration: TimeInterval {
        switch self {
        case .shield: 0
        case .magnet: 8
        case .doubleCoins: 10
        }
    }

    var isCharge: Bool { duration == 0 }
}

struct ActivePowerUp: Identifiable, Equatable {
    let kind: PowerUp
    let remaining: TimeInterval

    var id: String { kind.rawValue }

    var fraction: Double? {
        guard kind.duration > 0 else { return nil }
        return min(max(remaining / kind.duration, 0), 1)
    }
}
