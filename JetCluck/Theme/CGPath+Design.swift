import SwiftUI

extension CGPath {
    /// Moves an origin-centred, Y-up path - the way `PowerUpArt` and `CloudArt`
    /// author them - into a SwiftUI rect.
    func flipped(in rect: CGRect) -> Path {
        Path(self)
            .applying(CGAffineTransform(scaleX: 1, y: -1))
            .offsetBy(dx: rect.midX, dy: rect.midY)
    }
}
