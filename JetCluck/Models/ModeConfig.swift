import CoreGraphics
import Foundation

struct ModeConfig {
    enum Scoring {
        case seconds
        case coins
    }

    var scoring: Scoring = .seconds
    var usesFuel = false
    var initialFuel: Double = 10
    var fuelDrain: Double = 1
    var fuelPerCan: Double = 7
    var fuelInterval: TimeInterval = 5
    var obstaclesEnabled = true
    var obstacleStartInterval: TimeInterval = 2.7
    var obstacleFloorInterval: TimeInterval = 1.45
    var obstacleIntervalRamp: Double = 0.012
    var obstacleStartTravel: TimeInterval = 4.8
    var obstacleFloorTravel: TimeInterval = 3.15
    var obstacleTravelRamp: Double = 0.011
    var pairChance: Double = 0
    var coinInterval: TimeInterval = 2.1
    var coinValue = 1
    var coinRun = 3
    /// How long a coin, fuel can or power-up takes to cross the screen.
    var itemTravel: TimeInterval = 5.2
    var powerUps: [PowerUp] = []
    var powerUpInterval: TimeInterval = 16
    var timeLimit: TimeInterval?
    var scrollSpeed: CGFloat = 78
    var skyHex = "85CEE5"
    var tintHex: String?
    var tintAlpha: CGFloat = 0

    var scoreUnit: String {
        switch scoring {
        case .seconds: "SEC"
        case .coins: "COINS"
        }
    }

    func obstacleInterval(at elapsed: TimeInterval) -> TimeInterval {
        max(obstacleFloorInterval, obstacleStartInterval - elapsed * obstacleIntervalRamp)
    }

    func obstacleTravel(at elapsed: TimeInterval) -> TimeInterval {
        max(obstacleFloorTravel, obstacleStartTravel - elapsed * obstacleTravelRamp)
    }
}
