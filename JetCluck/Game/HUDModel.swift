import Combine
import Foundation

/// Holds the fast-changing run values so the HUD refreshes without redrawing
/// the whole game screen.
@MainActor
final class HUDModel: ObservableObject {
    @Published private(set) var snapshot: GameRunSnapshot

    let mode: GameMode

    init(mode: GameMode) {
        self.mode = mode
        snapshot = Self.initialSnapshot(for: mode)
    }

    func apply(_ snapshot: GameRunSnapshot) {
        self.snapshot = snapshot
    }

    func reset() {
        snapshot = Self.initialSnapshot(for: mode)
    }

    private static func initialSnapshot(for mode: GameMode) -> GameRunSnapshot {
        GameRunSnapshot(
            fuel: mode.config.initialFuel,
            timeRemaining: mode.config.timeLimit
        )
    }
}
