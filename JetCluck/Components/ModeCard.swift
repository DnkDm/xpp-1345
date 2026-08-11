import SwiftUI

struct ModeCard: View {
    let mode: GameMode
    let best: Int
    let isUnlocked: Bool
    let unlock: (value: Int, goal: Int)
    let action: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 14) {
                Image(mode.iconAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 58, height: 58)
                    .saturation(isUnlocked ? 1 : 0)

                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.title.uppercased())
                        .font(.cluck(24))
                        .foregroundStyle(AppPalette.brown)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(mode.tagline)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(AppPalette.ink.opacity(0.72))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if isUnlocked {
                Text("BEST: \(best) \(mode.config.scoreUnit)")
                    .font(.cluck(16))
                    .foregroundStyle(AppPalette.brown)

                FigmaImageButton(
                    assetName: "CompactPlay",
                    size: CGSize(width: 270, height: 54),
                    action: action
                )
            } else {
                lockedFooter
            }
        }
        .padding(20)
        .frame(maxWidth: 342)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppPalette.panel)
                .stroke(AppPalette.brown, lineWidth: 4)
        )
        .opacity(isUnlocked ? 1 : 0.82)
    }

    private var lockedFooter: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                LockGlyph()
                    .frame(width: 16, height: 20)
                Text(mode.unlock.requirement)
                    .font(.cluck(14))
                    .foregroundStyle(AppPalette.brown)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
            }

            ProgressBar(fraction: fraction)
                .frame(width: 250, height: 12)

            Text("\(min(unlock.value, unlock.goal)) / \(unlock.goal)")
                .font(.cluck(14))
                .foregroundStyle(AppPalette.ink.opacity(0.6))
                .monospacedDigit()
        }
        .frame(height: 78)
    }

    private var fraction: Double {
        guard unlock.goal > 0 else { return 0 }
        return min(Double(unlock.value) / Double(unlock.goal), 1)
    }
}

struct ProgressBar: View {
    let fraction: Double

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppPalette.brown.opacity(0.18))
                Capsule()
                    .fill(AppPalette.ticketShadow)
                    .frame(width: proxy.size.width * min(max(fraction, 0), 1))
            }
        }
    }
}
