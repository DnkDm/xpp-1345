@preconcurrency import SpriteKit

/// A drone or a crow crossing the climb. Same artwork as the flight game, but
/// here they own their horizontal movement instead of being pulled by actions,
/// because the scene rewrites every position each frame.
final class HazardNode: SKSpriteNode {
    enum Kind: CaseIterable {
        case drone
        case bird
    }

    let kind: Kind
    /// Points per second, sign included.
    var travel: CGFloat

    init(kind: Kind, travel: CGFloat, world: CGFloat) {
        self.kind = kind
        self.travel = travel
        let texture = SKTexture(
            imageNamed: kind == .drone ? "DroneObstacle" : "BirdObstacle"
        )
        let size = kind == .drone
            ? CGSize(width: 94 * world, height: 64 * world)
            : CGSize(width: 88 * world, height: 82 * world)
        super.init(texture: texture, color: .clear, size: size)

        zPosition = 6
        faceTravelDirection()
        physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(width: size.width * 0.66, height: size.height * 0.5)
        )
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = HopCategory.hazard
        physicsBody?.contactTestBitMask = HopCategory.chicken
        physicsBody?.collisionBitMask = 0
    }

    required init?(coder aDecoder: NSCoder) {
        nil
    }

    func turnAround() {
        travel = -travel
        faceTravelDirection()
    }

    /// Puffs the hazard away when a boosting chicken flies straight through it.
    func burstApart() {
        physicsBody = nil
        run(.sequence([
            .group([
                .fadeOut(withDuration: 0.24),
                .scale(to: 1.5, duration: 0.24)
            ]),
            .removeFromParent()
        ]))
    }

    /// The crow is drawn facing right; the drone is symmetric.
    private func faceTravelDirection() {
        guard kind == .bird else { return }
        xScale = travel < 0 ? -1 : 1
    }
}
