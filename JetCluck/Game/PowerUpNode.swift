@preconcurrency import SpriteKit

enum PowerUpNode {
    static let radius: CGFloat = 26

    /// The pickup lives inside a wrapper so the caller can scale it for the
    /// device without disturbing the idle pulse.
    static func make(_ kind: PowerUp) -> SKNode {
        let node = SKNode()
        node.name = "powerUp"
        node.userData = ["kind": kind.rawValue]
        node.zPosition = 7

        let body = SKNode()
        let badge = SKShapeNode(circleOfRadius: radius)
        badge.fillColor = UIColor(hex: "FED058")
        badge.strokeColor = UIColor(hex: "9A4A25")
        badge.lineWidth = 4
        body.addChild(badge)
        body.addChild(glyph(for: kind))
        node.addChild(body)

        body.run(.repeatForever(.sequence([
            .scale(to: 1.09, duration: 0.55),
            .scale(to: 0.95, duration: 0.55)
        ])))
        return node
    }

    private static func glyph(for kind: PowerUp) -> SKNode {
        switch kind {
        case .shield: shieldGlyph()
        case .magnet: magnetGlyph()
        case .doubleCoins: doubleCoinsGlyph()
        }
    }

    private static func shieldGlyph() -> SKNode {
        let shield = SKShapeNode(path: PowerUpArt.shield(size: 34))
        shield.fillColor = UIColor(hex: "FFF0BA")
        shield.strokeColor = UIColor(hex: "9A4A25")
        shield.lineWidth = 3
        shield.lineJoin = .round
        return shield
    }

    private static func magnetGlyph() -> SKNode {
        let node = SKNode()

        let body = SKShapeNode(path: PowerUpArt.magnetBody(size: 34))
        body.strokeColor = UIColor(hex: "EF5548")
        body.lineWidth = PowerUpArt.magnetLineWidth(size: 34)
        body.lineCap = .butt
        body.fillColor = .clear
        node.addChild(body)

        for tip in PowerUpArt.magnetTips(size: 34) {
            let pole = SKShapeNode(rect: tip)
            pole.fillColor = UIColor(hex: "FFF0BA")
            pole.strokeColor = UIColor(hex: "9A4A25")
            pole.lineWidth = 2
            node.addChild(pole)
        }
        return node
    }

    private static func doubleCoinsGlyph() -> SKNode {
        let node = SKNode()

        let coin = SKSpriteNode(imageNamed: "Coin")
        coin.size = CGSize(width: 28, height: 28)
        coin.position = CGPoint(x: 0, y: 5)
        node.addChild(coin)

        let label = SKLabelNode(fontNamed: "FredokaOne-Regular")
        label.text = "x2"
        label.fontSize = 14
        label.fontColor = UIColor(hex: "9A4A25")
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -15)
        node.addChild(label)

        return node
    }
}
