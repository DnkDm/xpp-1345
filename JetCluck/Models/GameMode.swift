import Foundation

enum GameMode: String, CaseIterable, Codable, Equatable, Identifiable {
    case fuel
    case free
    case rush
    case coinRush
    case nightmare

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fuel: "Fuel Flight"
        case .free: "Free Flight"
        case .rush: "Rush Hour"
        case .coinRush: "Coin Rush"
        case .nightmare: "Night Storm"
        }
    }

    var tagline: String {
        switch self {
        case .fuel: "Collect fuel, dodge birds and drones."
        case .free: "No fuel. No obstacles. Just keep flying."
        case .rush: "No fuel gauge, only traffic - and it keeps coming."
        case .coinRush: "60 seconds. Grab every coin you can reach."
        case .nightmare: "Dusk, thin fuel, packed skies. Coins pay triple."
        }
    }

    var hint: String {
        switch self {
        case .fuel: "HOLD TO FLY\nRELEASE TO FALL"
        case .free: "HOLD TO FLY\nTAKE YOUR TIME"
        case .rush: "HOLD TO FLY\nTRAFFIC INCOMING"
        case .coinRush: "HOLD TO FLY\n60 SECONDS OF GOLD"
        case .nightmare: "HOLD TO FLY\nFUEL BURNS FAST"
        }
    }

    var iconAsset: String {
        switch self {
        case .fuel: "FuelModeIcon"
        case .free: "FreeModeIcon"
        case .rush: "DroneObstacle"
        case .coinRush: "HUDCoin"
        case .nightmare: "BirdObstacle"
        }
    }

    var unlock: UnlockRule {
        switch self {
        case .fuel, .free: .always
        case .rush: .score(.fuel, 25)
        case .coinRush: .totalCoins(120)
        case .nightmare: .score(.rush, 40)
        }
    }

    var config: ModeConfig {
        switch self {
        case .fuel:
            ModeConfig(
                usesFuel: true,
                powerUps: [.shield, .magnet, .doubleCoins]
            )
        case .free:
            ModeConfig(
                obstaclesEnabled: false,
                coinInterval: 1.9,
                coinRun: 5,
                itemTravel: 5.6,
                scrollSpeed: 66
            )
        case .rush:
            ModeConfig(
                obstacleStartInterval: 1.9,
                obstacleFloorInterval: 1,
                obstacleIntervalRamp: 0.02,
                obstacleStartTravel: 3.9,
                obstacleFloorTravel: 2.35,
                obstacleTravelRamp: 0.016,
                pairChance: 0.22,
                coinInterval: 2.4,
                coinValue: 2,
                itemTravel: 4,
                powerUps: [.shield, .magnet, .doubleCoins],
                powerUpInterval: 13,
                scrollSpeed: 110
            )
        case .coinRush:
            ModeConfig(
                scoring: .coins,
                obstacleStartInterval: 2.6,
                obstacleFloorInterval: 1.8,
                obstacleIntervalRamp: 0.01,
                obstacleStartTravel: 4.6,
                obstacleFloorTravel: 3.6,
                coinInterval: 1.25,
                coinRun: 6,
                itemTravel: 4.8,
                powerUps: [.magnet, .doubleCoins],
                powerUpInterval: 10,
                timeLimit: 60,
                scrollSpeed: 84,
                skyHex: "F7BE63"
            )
        case .nightmare:
            ModeConfig(
                usesFuel: true,
                initialFuel: 8,
                fuelDrain: 1.35,
                fuelPerCan: 6,
                fuelInterval: 6,
                obstacleStartInterval: 2,
                obstacleFloorInterval: 0.95,
                obstacleIntervalRamp: 0.02,
                obstacleStartTravel: 3.8,
                obstacleFloorTravel: 2.3,
                obstacleTravelRamp: 0.017,
                pairChance: 0.34,
                coinInterval: 2.2,
                coinValue: 3,
                coinRun: 2,
                itemTravel: 4.2,
                powerUps: [.shield, .magnet, .doubleCoins],
                powerUpInterval: 15,
                scrollSpeed: 95,
                skyHex: "6E8FB8",
                tintHex: "17244A",
                tintAlpha: 0.24
            )
        }
    }
}

enum UnlockRule {
    case always
    case score(GameMode, Int)
    case totalCoins(Int)
    case hopHeight(Int)

    var requirement: String {
        switch self {
        case .always:
            ""
        case .score(let mode, let value):
            "Reach \(value) \(mode.config.scoreUnit) in \(mode.title.uppercased())"
        case .totalCoins(let value):
            "Collect \(value) coins in total"
        case .hopHeight(let value):
            "Climb \(value) m in SKY HOP"
        }
    }
}
