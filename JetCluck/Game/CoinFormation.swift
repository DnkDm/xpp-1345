import CoreGraphics
import Foundation

enum CoinFormation: CaseIterable {
    case line
    case arc
    case wave
    case stack

    static let spacing: CGFloat = 52

    /// Offsets relative to the first coin of the run. X grows to the right, so a
    /// run spawned off-screen arrives one coin at a time.
    func offsets(count: Int) -> [CGPoint] {
        guard count > 1 else { return [.zero] }
        let last = CGFloat(count - 1)

        return (0..<count).map { index in
            let step = CGFloat(index)
            let phase = step / last

            switch self {
            case .line:
                return CGPoint(x: step * Self.spacing, y: 0)
            case .arc:
                return CGPoint(x: step * Self.spacing, y: sin(phase * .pi) * 62)
            case .wave:
                return CGPoint(x: step * Self.spacing, y: sin(phase * .pi * 2) * 48)
            case .stack:
                return CGPoint(x: 0, y: (step - last / 2) * 44)
            }
        }
    }
}
