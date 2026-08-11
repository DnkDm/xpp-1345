import Foundation

struct GameRunStats {
    let seconds: Int
    let score: Int
    let coins: Int
    let fuelCans: Int
    let birdStreak: Int
    let droneStreak: Int
    let powerUps: Int
    let outcome: GameOutcome
}

enum GameOutcome {
    case crashed
    case outOfFuel
    case timeUp

    var title: String {
        switch self {
        case .crashed: "Game Over"
        case .outOfFuel: "Out of Fuel"
        case .timeUp: "Time Up"
        }
    }
}

struct GameRunSnapshot {
    var score = 0
    var coins = 0
    var fuel: Double = 0
    var timeRemaining: TimeInterval?
    var powerUps: [ActivePowerUp] = []
}
