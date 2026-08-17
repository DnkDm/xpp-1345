import SwiftUI

/// One mode on a mode-picking screen. Both games fill it in, so a flight mode
/// and a climb read the same way.
struct ModeCard<Icon: View>: View {
    let title: String
    let tagline: String
    let bestText: String
    /// Nil keeps the drawn PLAY artwork, which already says FLY on it. A game
    /// that is not flown passes its own verb instead.
    var playLabel: String?
    let isUnlocked: Bool
    let requirement: String
    let unlock: (value: Int, goal: Int)
    let action: () -> Void
    @ViewBuilder private let icon: Icon

    init(
        title: String,
        tagline: String,
        bestText: String,
        playLabel: String? = nil,
        isUnlocked: Bool,
        requirement: String,
        unlock: (value: Int, goal: Int),
        action: @escaping () -> Void,
        @ViewBuilder icon: () -> Icon
    ) {
        self.title = title
        self.tagline = tagline
        self.bestText = bestText
        self.playLabel = playLabel
        self.isUnlocked = isUnlocked
        self.requirement = requirement
        self.unlock = unlock
        self.action = action
        self.icon = icon()
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 14) {
                icon
                    .frame(width: 58, height: 58)
                    .saturation(isUnlocked ? 1 : 0)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title.uppercased())
                        .font(.cluck(24))
                        .foregroundStyle(AppPalette.brown)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(tagline)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(AppPalette.ink.opacity(0.72))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if isUnlocked {
                Text(bestText.uppercased())
                    .font(.cluck(16))
                    .foregroundStyle(AppPalette.brown)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if let playLabel {
                    TicketButton(title: playLabel, compact: true, action: action)
                } else {
                    FigmaImageButton(
                        assetName: "CompactPlay",
                        size: CGSize(width: 270, height: 54),
                        action: action
                    )
                }
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
                Text(requirement)
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
