import CoreGraphics
import Foundation

/// What makes one Sky Hop climb different from another. Every value is either
/// a plain number or a factor on the shared curves in `HopTuning`, so a mode is
/// a short list of differences instead of a second copy of the game.
struct HopConfig {
    var gravity: CGFloat = HopTuning.gravity
    var bounceSpeed: CGFloat = HopTuning.bounceSpeed
    /// Added to the cloud width at every height - a wider cloud is a kinder one.
    var cloudWidthBonus: CGFloat = 0
    var gapScale: CGFloat = 1
    var driftingScale: Double = 1
    var stormScale: Double = 1
    var hazardsEnabled = true
    var hazardsFrom = HopTuning.hazardsFrom
    var hazardSpacingScale: CGFloat = 1
    var jetCansEnabled = true
    var coinValue = 1
    var duskAt = HopTuning.duskAt
    var nightAt = HopTuning.nightAt

    /// How high one bounce reaches. Every mode is tuned to the same apex, so
    /// the clouds always sit within reach no matter how fast the mode plays.
    var bounceApex: CGFloat {
        bounceSpeed * bounceSpeed / (2 * -gravity)
    }

    func cloudWidth(at metres: Int) -> CGFloat {
        HopTuning.cloudWidth(at: metres) + cloudWidthBonus
    }

    /// Clamped against the apex, so no run can be handed a gap it cannot jump.
    func gap(at metres: Int) -> CGFloat {
        min(HopTuning.gap(at: metres) * gapScale, bounceApex - 40)
    }

    func driftingChance(at metres: Int) -> Double {
        HopTuning.driftingChance(at: metres) * driftingScale
    }

    func stormChance(at metres: Int) -> Double {
        HopTuning.stormChance(at: metres) * stormScale
    }

    func hazardSpacing(at metres: Int) -> CGFloat {
        HopTuning.hazardSpacing(at: metres) * hazardSpacingScale
    }
}
