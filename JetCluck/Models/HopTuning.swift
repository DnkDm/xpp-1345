import CoreGraphics
import Foundation

/// Every number Sky Hop is balanced on, in the 390x844 design space. The scene
/// multiplies distances and speeds by its world scale, so an iPad plays exactly
/// like a phone instead of just seeing more sky.
///
/// Difficulty is written against metres rather than seconds: a careful player
/// and a fast one meet the same clouds, only at their own pace.
enum HopTuning {
    /// Points of climb that count as one metre on the HUD. One screen of sky
    /// is about 35 metres.
    static let metre: CGFloat = 24

    // MARK: - Chicken

    static let gravity: CGFloat = -2350
    static let bounceSpeed: CGFloat = 980
    /// Capped so the chicken can never fall through a cloud between frames.
    static let fallSpeedLimit: CGFloat = -1250
    /// Distance from the chicken's centre down to its feet.
    static let footOffset: CGFloat = 30
    /// A flick of the finger moves the chicken a good deal further than itself,
    /// so crossing to the far side of the screen is a thumb-sized swipe.
    static let steerFactor: CGFloat = 1.8
    static let steerSpeedLimit: CGFloat = 1600
    /// Stops a fast flick from drifting on after the finger has stopped, while
    /// still leaving room for the whole flick to land.
    static let steerBacklog: CGFloat = 140

    // MARK: - Jet can

    static let boostSpeed: CGFloat = 1150
    static let boostDuration: TimeInterval = 1.3
    /// Roughly how many clouds apart the jet cans sit.
    static let cansEvery = 13

    // MARK: - World

    /// The chicken never climbs past this share of the screen - the world
    /// scrolls down instead.
    static let cameraLine: CGFloat = 0.56
    static let cloudHeight: CGFloat = 46
    static let spawnMargin: CGFloat = 150
    static let despawnMargin: CGFloat = 190

    static func cloudWidth(at metres: Int) -> CGFloat {
        max(84, 124 - CGFloat(metres) * 0.22)
    }

    /// A bounce peaks about 204 points up, so even the widest gap leaves room
    /// to steer on the way.
    static func gap(at metres: Int) -> CGFloat {
        min(94 + CGFloat(metres) * 0.42, 152)
    }

    /// How far sideways the next cloud sits, as a share of the screen width.
    /// The lower bound is what keeps the game a game: it is wider than a cloud,
    /// so a chicken left alone always drops straight past the next one.
    static let minShift: CGFloat = 0.20
    /// The upper bound is what keeps it fair - this much is reachable in the
    /// time one bounce hangs in the air.
    static let maxShift: CGFloat = 0.55

    static func driftSpeed(at metres: Int) -> CGFloat {
        min(58 + CGFloat(metres) * 0.5, 130)
    }

    static func driftingChance(at metres: Int) -> Double {
        ramp(metres, from: 15, to: 80, peak: 0.30)
    }

    static func stormChance(at metres: Int) -> Double {
        ramp(metres, from: 35, to: 150, peak: 0.26)
    }

    static let coinChance = 0.34
    static let coinRunChance = 0.16

    // MARK: - Hazards

    static let hazardsFrom = 45
    static func hazardSpeed(at metres: Int) -> CGFloat {
        min(85 + CGFloat(metres) * 0.35, 175)
    }

    /// Points of climb between two hazards.
    static func hazardSpacing(at metres: Int) -> CGFloat {
        max(640, 1300 - CGFloat(metres) * 4)
    }

    // MARK: - Sky

    /// Metres at which the sky has finished turning to dusk, and to night.
    static let duskAt: CGFloat = 120
    static let nightAt: CGFloat = 300

    private static func ramp(
        _ metres: Int,
        from start: Int,
        to end: Int,
        peak: Double
    ) -> Double {
        guard metres > start else { return 0 }
        guard metres < end else { return peak }
        return peak * Double(metres - start) / Double(end - start)
    }
}
