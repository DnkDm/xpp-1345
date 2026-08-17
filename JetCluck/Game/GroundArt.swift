@preconcurrency import SpriteKit

/// The rolling green ground with its trees. Shared by both games so the farm
/// looks the same whether the chicken is flying across it or bouncing off it.
enum GroundArt {
    static let segmentWidth: CGFloat = 600

    /// Height of the grass at a point along a segment. Two sine waves, so the
    /// hills never repeat in an obvious rhythm.
    static func surfaceY(at x: CGFloat) -> CGFloat {
        let phase = x / segmentWidth * .pi * 2
        return 94 + sin(phase) * 27 + sin(phase * 2 + 0.55) * 8
    }

    /// One tile of ground. `index` only decides which trees are the tall ones,
    /// so neighbouring tiles do not look copy-pasted.
    static func makeSegment(index: Int, world: CGFloat) -> SKNode {
        let segment = SKNode()
        segment.setScale(world)
        segment.position.x = CGFloat(index) * segmentWidth * world

        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: 0, y: surfaceY(at: 0)))
        stride(from: CGFloat(8), to: segmentWidth, by: 8).forEach { x in
            path.addLine(to: CGPoint(x: x, y: surfaceY(at: x)))
        }
        path.addLine(to: CGPoint(x: segmentWidth, y: surfaceY(at: segmentWidth)))
        path.addLine(to: CGPoint(x: segmentWidth, y: 0))
        path.closeSubpath()

        let ground = SKShapeNode(path: path)
        ground.fillColor = SKColor(red: 0.05, green: 0.64, blue: 0.43, alpha: 1)
        ground.strokeColor = .clear
        segment.addChild(ground)

        for (treeIndex, x) in [CGFloat(88), 278, 482].enumerated() {
            let tall = (treeIndex + index).isMultiple(of: 2)
            let tree = SKSpriteNode(imageNamed: tall ? "GameTree2" : "GameTree1")
            let scale = CGFloat.random(in: 0.86...1.08)
            tree.size = tall
                ? CGSize(width: 120 * scale, height: 180 * scale)
                : CGSize(width: 120 * scale, height: 132 * scale)
            tree.position = CGPoint(
                x: x,
                y: surfaceY(at: x) - 14 + tree.size.height / 2
            )
            // Behind the grass, so the hill hides the buried part of the trunk.
            tree.zPosition = -1
            segment.addChild(tree)
        }

        return segment
    }
}
