import UIKit

/// Sky Hop bounces about twice a second, so the tap that goes with it stays
/// soft; only landing a jet can or crashing gets a firm one. Follows the sound
/// switch, because that is where a player goes to make the game quiet.
@MainActor
enum Haptics {
    private static let soft = UIImpactFeedbackGenerator(style: .soft)
    private static let firm = UIImpactFeedbackGenerator(style: .medium)

    static func prepare() {
        soft.prepare()
        firm.prepare()
    }

    static func bounce() {
        guard AudioManager.shared.soundEnabled else { return }
        soft.impactOccurred(intensity: 0.55)
    }

    static func punch() {
        guard AudioManager.shared.soundEnabled else { return }
        firm.impactOccurred()
    }
}
