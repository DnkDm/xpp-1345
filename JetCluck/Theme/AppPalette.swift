import SwiftUI

enum AppPalette {
    static let sky = Color(hex: Hex.daySky)
    static let skyDark = Color(hex: "5AB8D8")
    static let ticket = Color(hex: "FED058")
    static let ticketShadow = Color(hex: "EDAE44")
    static let ticketHighlight = Color(hex: "FFF0BA")
    static let brown = Color(hex: "9A4A25")
    static let ink = Color(hex: "30201A")
    static let panel = Color.white.opacity(0.94)
    static let green = Color(hex: "75BF5A")
    static let red = Color(hex: "EF5548")
    /// The dark line every piece of artwork is drawn with.
    static let outline = Color(hex: Hex.outline)

    /// Raw values for the SpriteKit side, which builds `UIColor` instead.
    enum Hex {
        static let outline = "553A22"
        static let cloudFold = "A9D6EC"
        static let cloudStreak = "7FB8D6"
        static let stormCloud = "CBD9E3"
        static let stormFold = "97AEBF"
        static let daySky = "85CEE5"
        static let duskSky = "3C5D9E"
        static let nightSky = "141F4B"
        static let flame = "F5A623"
        static let flameCore = "FFE07A"
    }
}
