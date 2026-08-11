import SwiftUI

/// SwiftUI twin of the SpriteKit pickup, drawn from the same paths.
struct PowerUpGlyph: View {
    let kind: PowerUp

    var body: some View {
        switch kind {
        case .shield:
            ShieldShape()
                .fill(AppPalette.ticketHighlight)
                .overlay(ShieldShape().stroke(AppPalette.brown, lineWidth: 2.5))
        case .magnet:
            GeometryReader { proxy in
                let side = min(proxy.size.width, proxy.size.height)
                ZStack {
                    MagnetBodyShape()
                        .stroke(
                            AppPalette.red,
                            style: StrokeStyle(lineWidth: PowerUpArt.magnetLineWidth(size: side))
                        )
                    MagnetTipsShape()
                        .fill(AppPalette.ticketHighlight)
                    MagnetTipsShape()
                        .stroke(AppPalette.brown, lineWidth: 1.5)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
        case .doubleCoins:
            VStack(spacing: 0) {
                Image("Coin")
                    .resizable()
                    .scaledToFit()
                Text("x2")
                    .font(.cluck(11))
                    .foregroundStyle(AppPalette.brown)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        }
    }
}

private struct ShieldShape: Shape {
    func path(in rect: CGRect) -> Path {
        PowerUpArt.shield(size: min(rect.width, rect.height)).flipped(in: rect)
    }
}

private struct MagnetBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        PowerUpArt.magnetBody(size: min(rect.width, rect.height)).flipped(in: rect)
    }
}

private struct MagnetTipsShape: Shape {
    func path(in rect: CGRect) -> Path {
        let tips = PowerUpArt.magnetTips(size: min(rect.width, rect.height))
        let path = CGMutablePath()
        tips.forEach { path.addRect($0) }
        return path.flipped(in: rect)
    }
}

private extension CGPath {
    /// Moves an origin-centred, Y-up path into a SwiftUI rect.
    func flipped(in rect: CGRect) -> Path {
        Path(self)
            .applying(CGAffineTransform(scaleX: 1, y: -1))
            .offsetBy(dx: rect.midX, dy: rect.midY)
    }
}
