import SwiftUI

/// iPad-only layout adjustments. Every value falls back to the original iPhone
/// number on iPhone, so the phone build is untouched.
enum DeviceLayout {
    static let isPad = UIDevice.current.userInterfaceIdiom == .pad

    /// The screen the whole UI was designed against.
    static let designSize = CGSize(width: 390, height: 844)

    /// Fixed-size chrome (header, HUD, dialogs) is drawn larger on iPad so it
    /// does not look lost on a big screen.
    static let chromeScale: CGFloat = isPad ? 1.45 : 1

    /// Ceiling for the 390x844 design canvas: the button artwork is authored at
    /// 1x, so blowing it up further would soften it.
    static let maxCanvasScale: CGFloat = isPad ? 1.5 : .greatestFiniteMagnitude

    /// Scrolling lists keep a readable column instead of stretching edge to edge.
    static let maxContentWidth: CGFloat = isPad ? 720 : .infinity

    /// True when there is room for a multi-column layout - also false for a
    /// narrow iPad split-screen window, where the phone layout fits better.
    static func isWide(_ width: CGFloat) -> Bool {
        isPad && width >= 700
    }

    /// How much bigger the game world is drawn, so the chicken keeps its
    /// on-screen presence. Vertical play space stays identical to the phone.
    static func worldScale(for size: CGSize) -> CGFloat {
        guard isPad else { return 1 }
        let fit = min(size.width / designSize.width, size.height / designSize.height)
        return min(max(fit, 0.75), 2.2)
    }
}
