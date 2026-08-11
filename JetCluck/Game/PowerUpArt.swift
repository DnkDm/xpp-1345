import CoreGraphics

/// Vector artwork shared by the SpriteKit pickups and the SwiftUI HUD chips,
/// so both read as the same object. Paths are centred on the origin and use a
/// maths-style Y axis (up is positive).
enum PowerUpArt {
    static func shield(size: CGFloat) -> CGPath {
        let unit = size / 34
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 17 * unit))
        path.addLine(to: CGPoint(x: -13 * unit, y: 9 * unit))
        path.addLine(to: CGPoint(x: -13 * unit, y: -3 * unit))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: -17 * unit),
            control: CGPoint(x: -12 * unit, y: -13 * unit)
        )
        path.addQuadCurve(
            to: CGPoint(x: 13 * unit, y: -3 * unit),
            control: CGPoint(x: 12 * unit, y: -13 * unit)
        )
        path.addLine(to: CGPoint(x: 13 * unit, y: 9 * unit))
        path.closeSubpath()
        return path
    }

    /// Horseshoe body, meant to be stroked with `magnetLineWidth(size:)`.
    static func magnetBody(size: CGFloat) -> CGPath {
        let unit = size / 34
        let path = CGMutablePath()
        path.addArc(
            center: CGPoint(x: 0, y: -unit),
            radius: 10 * unit,
            startAngle: 0,
            endAngle: .pi,
            clockwise: false
        )
        return path
    }

    static func magnetLineWidth(size: CGFloat) -> CGFloat {
        size / 34 * 8
    }

    /// The two pole tips that close the horseshoe.
    static func magnetTips(size: CGFloat) -> [CGRect] {
        let unit = size / 34
        return [-1, 1].map { side in
            CGRect(
                x: side * 10 * unit - 4 * unit,
                y: -11 * unit,
                width: 8 * unit,
                height: 10 * unit
            )
        }
    }
}
