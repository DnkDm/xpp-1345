import SwiftUI

struct StatsPanel: View {
    @ObservedObject var progress: ProgressStore

    var body: some View {
        VStack(spacing: 14) {
            Text("PILOT LOG")
                .font(.cluck(22))
                .foregroundStyle(AppPalette.ticket)

            VStack(spacing: 11) {
                row(title: "Flights", value: "\(progress.gamesPlayed)")
                row(title: "Time in air", value: timeInAir)
                row(title: "Coins earned", value: "\(progress.totalCoinsCollected)")
                row(title: "Power-ups grabbed", value: "\(progress.powerUpsCollected)")
            }

            DashedDivider()

            VStack(spacing: 11) {
                ForEach(GameMode.allCases) { mode in
                    row(
                        title: mode.title,
                        value: progress.isUnlocked(mode)
                            ? "\(progress.best(mode)) \(mode.config.scoreUnit)"
                            : "LOCKED"
                    )
                }
            }
        }
        .padding(.vertical, 22)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppPalette.brown)
        )
    }

    private var timeInAir: String {
        let minutes = progress.totalSeconds / 60
        let seconds = progress.totalSeconds % 60
        return minutes > 0 ? "\(minutes)m \(seconds)s" : "\(seconds)s"
    }

    private func row(title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Text(title.uppercased())
                .font(.cluck(15))
                .foregroundStyle(AppPalette.ticketHighlight.opacity(0.82))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 8)

            Text(value.uppercased())
                .font(.cluck(15))
                .foregroundStyle(AppPalette.ticketHighlight)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}
