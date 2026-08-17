import SwiftUI

/// One game on the hub screen. Same panel as `ModeCard`, but it introduces a
/// whole game rather than a flight mode.
struct GameHubCard<Icon: View>: View {
    let title: String
    let tagline: String
    let best: String
    /// The verb on the button - each game gets its own.
    let play: String
    let action: () -> Void
    @ViewBuilder private let icon: Icon

    init(
        title: String,
        tagline: String,
        best: String,
        play: String,
        action: @escaping () -> Void,
        @ViewBuilder icon: () -> Icon
    ) {
        self.title = title
        self.tagline = tagline
        self.best = best
        self.play = play
        self.action = action
        self.icon = icon()
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 14) {
                icon
                    .frame(width: 76, height: 76)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title.uppercased())
                        .font(.cluck(26))
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

            Text(best.uppercased())
                .font(.cluck(16))
                .foregroundStyle(AppPalette.brown)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            TicketButton(title: play, compact: true, action: action)
        }
        .padding(20)
        .frame(maxWidth: 342)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppPalette.panel)
                .stroke(AppPalette.brown, lineWidth: 4)
        )
    }
}
