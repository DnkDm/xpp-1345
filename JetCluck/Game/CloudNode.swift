@preconcurrency import SpriteKit

/// A Sky Hop platform, drawn from `CloudArt` so it matches the cloud on the
/// game card. It carries its own gameplay state instead of `userData`, because
/// the scene reads it every frame.
final class CloudNode: SKShapeNode {
    enum Kind {
        /// Plain cloud, stays put and can be used again.
        case solid
        /// Slides from side to side.
        case drifting
        /// Breaks apart the moment it is used.
        case storm
    }

    let kind: Kind
    let cloudWidth: CGFloat
    /// Height of the springy part above the cloud's centre.
    let surface: CGFloat
    var drift: CGFloat = 0
    private(set) var isBroken = false

    init(kind: Kind, width: CGFloat, height: CGFloat, lineWidth: CGFloat) {
        self.kind = kind
        self.cloudWidth = width
        self.surface = height * 0.30
        super.init()

        path = CloudArt.cloud(width: width, height: height)
        fillColor = kind == .storm
            ? UIColor(hex: AppPalette.Hex.stormCloud)
            : .white
        strokeColor = UIColor(hex: AppPalette.Hex.outline)
        self.lineWidth = lineWidth
        lineJoin = .round
        if kind == .storm {
            // A dashed edge reads as "this one will not hold you".
            path = path?.copy(dashingWithPhase: 0, lengths: [10 * lineWidth / 3, 7 * lineWidth / 3])
            fillColor = .clear
            addChild(fill(width: width, height: height))
        }
        addChild(fold(width: width, height: height, lineWidth: lineWidth))
        if kind == .drifting {
            addChild(streaks(width: width, height: height, lineWidth: lineWidth))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        nil
    }

    /// Puffs the cloud away. Only fades and scales, because the scene owns
    /// `position` and a move action would fight it.
    func breakApart() {
        guard !isBroken else { return }
        isBroken = true
        run(.sequence([
            .group([
                .fadeOut(withDuration: 0.3),
                .scaleY(to: 0.55, duration: 0.3)
            ]),
            .removeFromParent()
        ]))
    }

    /// The dashed outline cannot be filled, so a storm cloud keeps its body in
    /// a separate solid shape underneath.
    private func fill(width: CGFloat, height: CGFloat) -> SKNode {
        let body = SKShapeNode(path: CloudArt.cloud(width: width, height: height))
        body.fillColor = UIColor(hex: AppPalette.Hex.stormCloud)
        body.strokeColor = .clear
        body.zPosition = -1
        return body
    }

    private func fold(width: CGFloat, height: CGFloat, lineWidth: CGFloat) -> SKNode {
        let crease = SKShapeNode(path: CloudArt.fold(width: width, height: height))
        crease.strokeColor = UIColor(
            hex: kind == .storm ? AppPalette.Hex.stormFold : AppPalette.Hex.cloudFold
        )
        crease.lineWidth = lineWidth * 0.8
        crease.lineCap = .round
        crease.fillColor = .clear
        return crease
    }

    private func streaks(width: CGFloat, height: CGFloat, lineWidth: CGFloat) -> SKNode {
        let marks = SKShapeNode(path: CloudArt.streaks(width: width, height: height))
        marks.strokeColor = UIColor(hex: AppPalette.Hex.cloudStreak)
        marks.lineWidth = lineWidth * 0.9
        marks.lineCap = .round
        marks.fillColor = .clear
        return marks
    }
}
