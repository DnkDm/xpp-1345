struct Quest: Identifiable {
    enum Metric {
        case bestFlightSeconds
        case bestFlightCoins
        case bestDroneStreak
        case skins
        case bestFuelCans
        case bestBirdStreak
        case totalCoins
        case gamesPlayed
        case totalSeconds
        case powerUps
        case modeScore(GameMode)
    }

    let id: String
    let title: String
    let goal: Int
    let reward: Int
    let metric: Metric
}
