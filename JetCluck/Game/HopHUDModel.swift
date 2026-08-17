import Combine
import Foundation

/// Holds the fast-changing run values so the HUD refreshes without redrawing
/// the whole game screen.
@MainActor
final class HopHUDModel: ObservableObject {
    @Published private(set) var snapshot = HopRunSnapshot()

    func apply(_ snapshot: HopRunSnapshot) {
        self.snapshot = snapshot
    }

    func reset() {
        snapshot = HopRunSnapshot()
    }
}
