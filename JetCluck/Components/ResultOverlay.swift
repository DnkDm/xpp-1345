import SwiftUI

/// End-of-run card. Both games fill it in, so a run always finishes the same
/// way no matter which one the player was in.
struct ResultOverlay: View {
    let sky: Color
    let title: String
    let coins: Int
    let scoreTitle: String
    let score: Int
    let bestTitle: String
    let best: Int
    /// Appended to both numbers, for a game whose score is not just a count.
    var unit: String?
    let isNewBest: Bool
    let onRestart: () -> Void
    let onHome: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let scale = min(
                (proxy.size.width - 24) / 390,
                (proxy.size.height - 24) / 844,
                DeviceLayout.maxCanvasScale
            )

            ZStack(alignment: .topLeading) {
                sky
                    .frame(width: 390, height: 844)

                RoundedRectangle(cornerRadius: 16)
                    .fill(AppPalette.ticketHighlight)
                    .stroke(AppPalette.brown, lineWidth: 4)
                    .frame(width: 342, height: 521)
                    .position(x: 195, y: 444.5)

                coinsEarned
                    .position(x: 195, y: 276)

                resultValue(title: scoreTitle, value: score)
                    .position(x: 195, y: 352)

                resultValue(title: bestTitle, value: best)
                    .position(x: 195, y: 488)

                if isNewBest {
                    newBestBadge
                        .position(x: 195, y: 566)
                }

                HStack(spacing: 24) {
                    resultButton(assetName: "RestartIcon", action: onRestart)
                    resultButton(assetName: "HomeIcon", action: onHome)
                }
                .position(x: 195, y: 633.5)

                resultRibbon
                    .position(x: 195, y: 207)
            }
            .frame(width: 390, height: 844)
            .scaleEffect(scale)
            .position(
                x: proxy.size.width / 2,
                y: proxy.size.height / 2
            )
        }
        .background(sky)
        .ignoresSafeArea()
    }

    private var resultRibbon: some View {
        ZStack {
            HStack(spacing: -14) {
                Image("ResultRibbonEnd")
                    .resizable()
                    .frame(width: 74, height: 78)
                    .rotationEffect(.degrees(-16))

                Color.clear.frame(width: 270, height: 74)

                Image("ResultRibbonEnd")
                    .resizable()
                    .frame(width: 74, height: 78)
                    .scaleEffect(x: -1)
                    .rotationEffect(.degrees(16))
            }

            RoundedRectangle(cornerRadius: 16)
                .fill(AppPalette.ticket)
                .stroke(AppPalette.ticketShadow, lineWidth: 4)
                .shadow(color: .black.opacity(0.24), radius: 4, y: 4)
                .frame(width: 270, height: 74)

            Text(title.uppercased())
                .font(.cluck(36))
                .foregroundStyle(AppPalette.brown)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .padding(.horizontal, 18)
        }
        .frame(width: 390, height: 94)
    }

    private var coinsEarned: some View {
        HStack(spacing: 8) {
            Image("Coin")
                .resizable()
                .scaledToFit()
                .frame(width: 34, height: 34)

            Text("+\(coins)")
                .font(.cluck(22))
                .foregroundStyle(AppPalette.brown)
                .monospacedDigit()
        }
        .frame(width: 222, height: 44)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppPalette.ticket)
                .stroke(AppPalette.ticketShadow, lineWidth: 3)
        )
    }

    private var newBestBadge: some View {
        Text("NEW BEST!")
            .font(.cluck(20))
            .foregroundStyle(AppPalette.ticketHighlight)
            .padding(.horizontal, 20)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(AppPalette.green)
            )
    }

    private func resultValue(title: String, value: Int) -> some View {
        VStack(spacing: 18) {
            Text(title.uppercased())
                .font(.cluck(24))
                .foregroundStyle(AppPalette.brown)
                .lineLimit(1)
                .minimumScaleFactor(0.65)

            Text(unit.map { "\(value) \($0)" } ?? "\(value)")
                .font(.cluck(36))
                .foregroundStyle(AppPalette.ticketHighlight)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .frame(width: 222, height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppPalette.brown)
                )
        }
        .frame(width: 270, height: 100)
    }

    private func resultButton(
        assetName: String,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            action()
            AudioManager.shared.play(.button)
        } label: {
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: 39, height: 39)
                .frame(width: 71, height: 71)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppPalette.ticket)
                        .stroke(AppPalette.ticketShadow, lineWidth: 4)
                        .shadow(color: AppPalette.ticketShadow, radius: 0, y: 4)
                )
        }
        .buttonStyle(.plain)
    }
}
