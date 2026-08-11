import Foundation

struct ProgressSnapshot: Codable {
    let coins: Int
    let bestFuel: Int
    let bestFree: Int
    let bestScores: [String: Int]
    let bestFlightSeconds: Int
    let gamesPlayed: Int
    let totalSeconds: Int
    let totalCoinsCollected: Int
    let bestFlightCoins: Int
    let bestFuelCans: Int
    let bestBirdStreak: Int
    let bestDroneStreak: Int
    let powerUpsCollected: Int
    let unlockedSkinIDs: [String]
    let claimedQuestIDs: [String]
    let selectedSkinID: String
    let musicEnabled: Bool
    let soundEnabled: Bool

    init(
        coins: Int,
        bestScores: [String: Int],
        bestFlightSeconds: Int,
        gamesPlayed: Int,
        totalSeconds: Int,
        totalCoinsCollected: Int,
        bestFlightCoins: Int,
        bestFuelCans: Int,
        bestBirdStreak: Int,
        bestDroneStreak: Int,
        powerUpsCollected: Int,
        unlockedSkinIDs: [String],
        claimedQuestIDs: [String],
        selectedSkinID: String,
        musicEnabled: Bool,
        soundEnabled: Bool
    ) {
        self.coins = coins
        self.bestFuel = bestScores[GameMode.fuel.rawValue] ?? 0
        self.bestFree = bestScores[GameMode.free.rawValue] ?? 0
        self.bestScores = bestScores
        self.bestFlightSeconds = bestFlightSeconds
        self.gamesPlayed = gamesPlayed
        self.totalSeconds = totalSeconds
        self.totalCoinsCollected = totalCoinsCollected
        self.bestFlightCoins = bestFlightCoins
        self.bestFuelCans = bestFuelCans
        self.bestBirdStreak = bestBirdStreak
        self.bestDroneStreak = bestDroneStreak
        self.powerUpsCollected = powerUpsCollected
        self.unlockedSkinIDs = unlockedSkinIDs
        self.claimedQuestIDs = claimedQuestIDs
        self.selectedSkinID = selectedSkinID
        self.musicEnabled = musicEnabled
        self.soundEnabled = soundEnabled
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        coins = try values.decodeIfPresent(Int.self, forKey: .coins) ?? 0
        bestFuel = try values.decodeIfPresent(Int.self, forKey: .bestFuel) ?? 0
        bestFree = try values.decodeIfPresent(Int.self, forKey: .bestFree) ?? 0
        gamesPlayed = try values.decodeIfPresent(Int.self, forKey: .gamesPlayed) ?? 0
        totalSeconds = try values.decodeIfPresent(Int.self, forKey: .totalSeconds) ?? 0
        totalCoinsCollected = try values.decodeIfPresent(Int.self, forKey: .totalCoinsCollected) ?? 0
        bestFlightCoins = try values.decodeIfPresent(Int.self, forKey: .bestFlightCoins) ?? 0
        bestFuelCans = try values.decodeIfPresent(Int.self, forKey: .bestFuelCans) ?? 0
        bestBirdStreak = try values.decodeIfPresent(Int.self, forKey: .bestBirdStreak) ?? 0
        bestDroneStreak = try values.decodeIfPresent(Int.self, forKey: .bestDroneStreak) ?? 0
        powerUpsCollected = try values.decodeIfPresent(Int.self, forKey: .powerUpsCollected) ?? 0
        unlockedSkinIDs = try values.decodeIfPresent([String].self, forKey: .unlockedSkinIDs) ?? ["classic"]
        claimedQuestIDs = try values.decodeIfPresent([String].self, forKey: .claimedQuestIDs) ?? []
        selectedSkinID = try values.decodeIfPresent(String.self, forKey: .selectedSkinID) ?? "classic"
        musicEnabled = try values.decodeIfPresent(Bool.self, forKey: .musicEnabled) ?? true
        soundEnabled = try values.decodeIfPresent(Bool.self, forKey: .soundEnabled) ?? true

        // Saves made before the extra modes shipped only knew two best scores.
        let storedScores = try values.decodeIfPresent([String: Int].self, forKey: .bestScores)
        bestScores = storedScores ?? [
            GameMode.fuel.rawValue: bestFuel,
            GameMode.free.rawValue: bestFree
        ]
        bestFlightSeconds = try values.decodeIfPresent(Int.self, forKey: .bestFlightSeconds)
            ?? max(bestFuel, bestFree)
    }
}
