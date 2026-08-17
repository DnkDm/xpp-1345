import CoreGraphics
import Foundation

/// Vector cloud shared by the Sky Hop platforms and the SwiftUI game card, so
/// both read as the same object. Paths are centred on the origin and use a
/// maths-style Y axis (up is positive), like `PowerUpArt`.
enum CloudArt {
    /// A cloud looks best a little over twice as wide as it is tall.
    static let aspect: CGFloat = 0.4

    /// Three overlapping bumps sitting on a flat base. The bumps are stitched
    /// at the points where the circles cross, so the outline stays one clean
    /// line instead of showing the seams between them.
    static func cloud(width: CGFloat, height: CGFloat) -> CGPath {
        let base = -height / 2
        let bottom = width * 0.47
        let left = Bump(
            centre: CGPoint(x: -width * 0.30, y: base + height * 0.30),
            radius: height * 0.30
        )
        let middle = Bump(
            centre: CGPoint(x: -width * 0.02, y: base + height * 0.52),
            radius: height * 0.48
        )
        let right = Bump(
            centre: CGPoint(x: width * 0.28, y: base + height * 0.36),
            radius: height * 0.35
        )

        let leftSeam = seam(left, middle)
        let rightSeam = seam(middle, right)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: -bottom, y: base))
        path.addArc(
            center: left.centre,
            radius: left.radius,
            startAngle: .pi,
            endAngle: left.angle(to: leftSeam),
            clockwise: true
        )
        path.addArc(
            center: middle.centre,
            radius: middle.radius,
            startAngle: middle.angle(to: leftSeam),
            endAngle: middle.angle(to: rightSeam),
            clockwise: true
        )
        path.addArc(
            center: right.centre,
            radius: right.radius,
            startAngle: right.angle(to: rightSeam),
            endAngle: 0,
            clockwise: true
        )
        path.addLine(to: CGPoint(x: bottom, y: base))
        path.closeSubpath()
        return path
    }

    /// The crease that stops the cloud from reading as a flat blob.
    static func fold(width: CGFloat, height: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let y = -height * 0.14
        path.move(to: CGPoint(x: -width * 0.27, y: y))
        path.addQuadCurve(
            to: CGPoint(x: width * 0.14, y: y),
            control: CGPoint(x: -width * 0.06, y: y - height * 0.26)
        )
        return path
    }

    /// Motion streaks that mark a cloud as one that slides sideways. They sit
    /// on the white body rather than out in the sky, so they read the same at
    /// noon and at midnight.
    static func streaks(width: CGFloat, height: CGFloat) -> CGPath {
        let path = CGMutablePath()
        for side in [CGFloat(-1), 1] {
            let outer = side * width * 0.38
            let inner = side * width * 0.22
            path.move(to: CGPoint(x: outer, y: height * 0.04))
            path.addLine(to: CGPoint(x: inner, y: height * 0.04))
            path.move(to: CGPoint(x: outer - side * width * 0.04, y: -height * 0.20))
            path.addLine(to: CGPoint(x: inner - side * width * 0.04, y: -height * 0.20))
        }
        return path
    }

    private struct Bump {
        let centre: CGPoint
        let radius: CGFloat

        func angle(to point: CGPoint) -> CGFloat {
            atan2(point.y - centre.y, point.x - centre.x)
        }
    }

    /// Where two bumps cross on the upper side. Falls back to the midpoint if
    /// the circles ever stop overlapping, so the path can never turn into NaN.
    private static func seam(_ first: Bump, _ second: Bump) -> CGPoint {
        let dx = second.centre.x - first.centre.x
        let dy = second.centre.y - first.centre.y
        let distance = sqrt(dx * dx + dy * dy)
        let midpoint = CGPoint(
            x: first.centre.x + dx / 2,
            y: first.centre.y + dy / 2
        )
        guard
            distance > 0,
            distance < first.radius + second.radius,
            distance > abs(first.radius - second.radius)
        else { return midpoint }

        let along = (first.radius * first.radius - second.radius * second.radius
            + distance * distance) / (2 * distance)
        let offset = sqrt(max(0, first.radius * first.radius - along * along))
        let unit = CGPoint(x: dx / distance, y: dy / distance)
        return CGPoint(
            x: first.centre.x + along * unit.x - offset * unit.y,
            y: first.centre.y + along * unit.y + offset * unit.x
        )
    }
}
