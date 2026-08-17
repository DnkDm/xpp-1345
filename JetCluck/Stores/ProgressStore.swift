import Combine
import Foundation

@MainActor
final class ProgressStore: ObservableObject {
    @Published private(set) var coins = 0
    @Published private(set) var bestScores: [String: Int] = [:]
    @Published private(set) var bestFlightSeconds = 0
    @Published private(set) var gamesPlayed = 0
    @Published private(set) var totalSeconds = 0
    @Published private(set) var totalCoinsCollected = 0
    @Published private(set) var bestFlightCoins = 0
    @Published private(set) var bestFuelCans = 0
    @Published private(set) var bestBirdStreak = 0
    @Published private(set) var bestDroneStreak = 0
    @Published private(set) var powerUpsCollected = 0
    @Published private(set) var bestHopHeight = 0
    @Published private(set) var hopBestScores: [String: Int] = [:]
    @Published private(set) var bestHopCoins = 0
    @Published private(set) var hopRuns = 0
    @Published private(set) var hopClouds = 0
    @Published private(set) var hopCans = 0
    @Published private(set) var unlockedSkinIDs: Set<String> = ["classic"]
    @Published private(set) var claimedQuestIDs: Set<String> = []
    @Published var selectedSkinID = "classic" { didSet { save() } }
    @Published var musicEnabled = true { didSet { save() } }
    @Published var soundEnabled = true { didSet { save() } }

    static let quests: [Quest] = [
        Quest(id: "sec10", title: "Fly for 20 seconds", goal: 20, reward: 10, metric: .bestFlightSeconds),
        Quest(id: "coin5", title: "Collect 8 coins\nin one flight", goal: 8, reward: 10, metric: .bestFlightCoins),
        Quest(id: "drone3", title: "Avoid 5 drones\nin a row", goal: 5, reward: 10, metric: .bestDroneStreak),
        Quest(id: "skin2", title: "Buy your first skin", goal: 2, reward: 10, metric: .skins),
        Quest(id: "play10", title: "Finish 10 flights", goal: 10, reward: 15, metric: .gamesPlayed),
        Quest(id: "hop40", title: "Climb 40m\nin Sky Hop", goal: 40, reward: 15, metric: .bestHopHeight),
        Quest(id: "hopCoin12", title: "Collect 12 coins\nin one climb", goal: 12, reward: 20, metric: .bestHopCoins),
        Quest(id: "sec30", title: "Fly for 45 seconds", goal: 45, reward: 20, metric: .bestFlightSeconds),
        Quest(id: "fuel10", title: "Collect 12 fuel\ncans in one run", goal: 12, reward: 20, metric: .bestFuelCans),
        Quest(id: "bird5", title: "Pass 10 birds\nwithout a touch", goal: 10, reward: 20, metric: .bestBirdStreak),
        Quest(id: "power10", title: "Grab 10 power-ups", goal: 10, reward: 20, metric: .powerUps),
        Quest(id: "skin5", title: "Unlock 5 skins", goal: 5, reward: 30, metric: .skins),
        Quest(id: "sec60", title: "Fly for 90 seconds", goal: 90, reward: 30, metric: .bestFlightSeconds),
        Quest(id: "coin50", title: "Collect 100 coins\nin total", goal: 100, reward: 30, metric: .totalCoins),
        Quest(id: "rush45", title: "Last 45 seconds\nin Rush Hour", goal: 45, reward: 30, metric: .modeScore(.rush)),
        Quest(id: "gold25", title: "Bank 25 coins\nin Coin Rush", goal: 25, reward: 30, metric: .modeScore(.coinRush)),
        Quest(id: "time10", title: "Spend 10 minutes\nin the air", goal: 600, reward: 30, metric: .totalSeconds),
        Quest(id: "hop90", title: "Climb 90m\nin Sky Hop", goal: 90, reward: 30, metric: .bestHopHeight),
        Quest(id: "hopCan10", title: "Grab 10 jet cans\nin Sky Hop", goal: 10, reward: 30, metric: .hopCans),
        Quest(id: "sec120", title: "Fly for 180 seconds", goal: 180, reward: 50, metric: .bestFlightSeconds),
        Quest(id: "coin100", title: "Collect 250 coins\nin total", goal: 250, reward: 50, metric: .totalCoins),
        Quest(id: "skin10", title: "Unlock 12 skins", goal: 12, reward: 50, metric: .skins),
        Quest(id: "drone10", title: "Avoid 20 drones\nin a row", goal: 20, reward: 50, metric: .bestDroneStreak),
        Quest(id: "bird20", title: "Pass 35 birds\nwithout a touch", goal: 35, reward: 50, metric: .bestBirdStreak),
        Quest(id: "play50", title: "Finish 50 flights", goal: 50, reward: 50, metric: .gamesPlayed),
        Quest(id: "hopRuns20", title: "Finish 20\nSky Hop climbs", goal: 20, reward: 50, metric: .hopRuns),
        Quest(id: "hop200", title: "Climb 200m\nin Sky Hop", goal: 200, reward: 60, metric: .bestHopHeight),
        Quest(id: "power40", title: "Grab 40 power-ups", goal: 40, reward: 50, metric: .powerUps),
        Quest(id: "night30", title: "Survive 30 seconds\nin Night Storm", goal: 30, reward: 60, metric: .modeScore(.nightmare)),
        Quest(id: "gold60", title: "Bank 60 coins\nin Coin Rush", goal: 60, reward: 60, metric: .modeScore(.coinRush)),
        Quest(id: "rush90", title: "Last 90 seconds\nin Rush Hour", goal: 90, reward: 80, metric: .modeScore(.rush)),
        Quest(id: "night60", title: "Survive 60 seconds\nin Night Storm", goal: 60, reward: 80, metric: .modeScore(.nightmare)),
        Quest(id: "skin25", title: "Unlock every skin", goal: ChickenSkin.all.count, reward: 100, metric: .skins),
        Quest(id: "coin1000", title: "Collect 1000 coins\nin total", goal: 1000, reward: 100, metric: .totalCoins)
    ]

    private let key = "jetCluck.progress.v1"
    private var isLoading = true

    init() {
        load()
        isLoading = false
    }

    var selectedSkin: ChickenSkin {
        ChickenSkin.all.first { $0.id == selectedSkinID } ?? ChickenSkin.all[0]
    }

    var unlockedModes: [GameMode] {
        GameMode.allCases.filter(isUnlocked)
    }

    func best(_ mode: GameMode) -> Int {
        bestScores[mode.rawValue] ?? 0
    }

    func best(_ mode: HopMode) -> Int {
        hopBestScores[mode.rawValue] ?? 0
    }

    func isUnlocked(_ mode: GameMode) -> Bool {
        unlockValue(for: mode.unlock) >= unlockGoal(for: mode.unlock)
    }

    func isUnlocked(_ mode: HopMode) -> Bool {
        unlockValue(for: mode.unlock) >= unlockGoal(for: mode.unlock)
    }

    func unlockProgress(for mode: GameMode) -> (value: Int, goal: Int) {
        (unlockValue(for: mode.unlock), unlockGoal(for: mode.unlock))
    }

    func unlockProgress(for mode: HopMode) -> (value: Int, goal: Int) {
        (unlockValue(for: mode.unlock), unlockGoal(for: mode.unlock))
    }

    func progress(for quest: Quest) -> Int {
        switch quest.metric {
        case .bestFlightSeconds: bestFlightSeconds
        case .bestFlightCoins: bestFlightCoins
        case .bestDroneStreak: bestDroneStreak
        case .skins: unlockedSkinIDs.count
        case .bestFuelCans: bestFuelCans
        case .bestBirdStreak: bestBirdStreak
        case .totalCoins: totalCoinsCollected
        case .gamesPlayed: gamesPlayed
        case .totalSeconds: totalSeconds
        case .powerUps: powerUpsCollected
        case .modeScore(let mode): best(mode)
        case .bestHopHeight: bestHopHeight
        case .bestHopCoins: bestHopCoins
        case .hopRuns: hopRuns
        case .hopCans: hopCans
        }
    }

    /// True when the run beat the stored best for its mode.
    func isNewBest(mode: GameMode, stats: GameRunStats) -> Bool {
        stats.score > best(mode)
    }

    func finishGame(mode: GameMode, stats: GameRunStats) {
        gamesPlayed += 1
        totalSeconds += stats.seconds
        totalCoinsCollected += stats.coins
        coins += stats.coins
        powerUpsCollected += stats.powerUps
        bestFlightSeconds = max(bestFlightSeconds, stats.seconds)
        bestFlightCoins = max(bestFlightCoins, stats.coins)
        bestFuelCans = max(bestFuelCans, stats.fuelCans)
        bestBirdStreak = max(bestBirdStreak, stats.birdStreak)
        bestDroneStreak = max(bestDroneStreak, stats.droneStreak)
        bestScores[mode.rawValue] = max(best(mode), stats.score)
        save()
    }

    /// True when the climb beat the stored best for its mode.
    func isNewBest(mode: HopMode, stats: HopRunStats) -> Bool {
        stats.height > best(mode)
    }

    /// Sky Hop keeps its own records, but pays into the same purse - coins
    /// earned up in the clouds buy skins in the shop.
    func finishHopRun(mode: HopMode, stats: HopRunStats) {
        hopRuns += 1
        hopBestScores[mode.rawValue] = max(best(mode), stats.height)
        hopClouds += stats.clouds
        hopCans += stats.cans
        coins += stats.coins
        totalCoinsCollected += stats.coins
        bestHopHeight = max(bestHopHeight, stats.height)
        bestHopCoins = max(bestHopCoins, stats.coins)
        save()
    }

    func buyOrSelect(_ skin: ChickenSkin) {
        if unlockedSkinIDs.contains(skin.id) {
            selectedSkinID = skin.id
        } else if coins >= skin.price {
            coins -= skin.price
            unlockedSkinIDs.insert(skin.id)
            selectedSkinID = skin.id
            save()
        }
    }

    func claim(_ quest: Quest) {
        guard progress(for: quest) >= quest.goal, !claimedQuestIDs.contains(quest.id) else { return }
        claimedQuestIDs.insert(quest.id)
        coins += quest.reward
        save()
    }

    private func unlockValue(for rule: UnlockRule) -> Int {
        switch rule {
        case .always: 1
        case .score(let mode, _): best(mode)
        case .totalCoins: totalCoinsCollected
        case .hopHeight: bestHopHeight
        }
    }

    private func unlockGoal(for rule: UnlockRule) -> Int {
        switch rule {
        case .always: 1
        case .score(_, let value): value
        case .totalCoins(let value): value
        case .hopHeight(let value): value
        }
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let snapshot = try? JSONDecoder().decode(ProgressSnapshot.self, from: data)
        else { return }
        coins = snapshot.coins
        bestScores = snapshot.bestScores
        bestFlightSeconds = snapshot.bestFlightSeconds
        gamesPlayed = snapshot.gamesPlayed
        totalSeconds = snapshot.totalSeconds
        totalCoinsCollected = snapshot.totalCoinsCollected
        bestFlightCoins = snapshot.bestFlightCoins
        bestFuelCans = snapshot.bestFuelCans
        bestBirdStreak = snapshot.bestBirdStreak
        bestDroneStreak = snapshot.bestDroneStreak
        powerUpsCollected = snapshot.powerUpsCollected
        bestHopHeight = snapshot.bestHopHeight
        hopBestScores = snapshot.hopBestScores
        bestHopCoins = snapshot.bestHopCoins
        hopRuns = snapshot.hopRuns
        hopClouds = snapshot.hopClouds
        hopCans = snapshot.hopCans
        unlockedSkinIDs = Set(snapshot.unlockedSkinIDs)
        claimedQuestIDs = Set(snapshot.claimedQuestIDs)
        selectedSkinID = snapshot.selectedSkinID
        musicEnabled = snapshot.musicEnabled
        soundEnabled = snapshot.soundEnabled
    }

    private func save() {
        guard !isLoading else { return }
        let snapshot = ProgressSnapshot(
            coins: coins,
            bestScores: bestScores,
            bestFlightSeconds: bestFlightSeconds,
            gamesPlayed: gamesPlayed,
            totalSeconds: totalSeconds,
            totalCoinsCollected: totalCoinsCollected,
            bestFlightCoins: bestFlightCoins,
            bestFuelCans: bestFuelCans,
            bestBirdStreak: bestBirdStreak,
            bestDroneStreak: bestDroneStreak,
            powerUpsCollected: powerUpsCollected,
            bestHopHeight: bestHopHeight,
            hopBestScores: hopBestScores,
            bestHopCoins: bestHopCoins,
            hopRuns: hopRuns,
            hopClouds: hopClouds,
            hopCans: hopCans,
            unlockedSkinIDs: Array(unlockedSkinIDs),
            claimedQuestIDs: Array(claimedQuestIDs),
            selectedSkinID: selectedSkinID,
            musicEnabled: musicEnabled,
            soundEnabled: soundEnabled
        )
        if let data = try? JSONEncoder().encode(snapshot) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
