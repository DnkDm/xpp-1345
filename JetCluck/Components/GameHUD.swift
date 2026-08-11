import SwiftUI

struct GameHUD: View {
    @ObservedObject var hud: HUDModel
    let onPause: () -> Void

    private let scale = DeviceLayout.chromeScale
    private var config: ModeConfig { hud.mode.config }
    private var snapshot: GameRunSnapshot { hud.snapshot }

    var body: some View {
        GeometryReader { proxy in
            let midX = proxy.size.width / 2

            ZStack(alignment: .topLeading) {
                pauseButton
                    .position(x: 46 * scale, y: 106 * scale)

                gauge
                    .frame(width: 206 * scale, height: 28 * scale)
                    .position(x: midX, y: 114 * scale)

                coinCounter
                    .position(x: proxy.size.width - 46 * scale, y: 109.5 * scale)

                Text("\(snapshot.score)")
                    .font(.cluck(48 * scale))
                    .foregroundStyle(AppPalette.brown)
                    .monospacedDigit()
                    .frame(width: 160 * scale)
                    .position(x: midX, y: 205 * scale)

                powerUpRow
                    .position(x: midX, y: 262 * scale)
            }
        }
        .frame(height: 300 * scale)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .ignoresSafeArea()
    }

    private var pauseButton: some View {
        Button(action: onPause) {
            Image("PauseButton")
                .resizable()
                .scaledToFit()
                .frame(width: 44 * scale, height: 44 * scale)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Pause")
    }

    @ViewBuilder
    private var gauge: some View {
        if config.usesFuel {
            meter(
                fill: min(max(snapshot.fuel / config.fuelPerCan, 0), 1),
                colors: [Color(hex: "CC3D33"), Color(hex: "E94D3F")]
            )
            .overlay(alignment: .leading) {
                Image("HUDFuel")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60 * scale, height: 60 * scale)
                    .offset(x: -16 * scale)
            }
        } else if let remaining = snapshot.timeRemaining, let limit = config.timeLimit {
            meter(
                fill: min(max(remaining / limit, 0), 1),
                colors: [Color(hex: "0CA46D"), AppPalette.green]
            )
            .overlay {
                Text("\(Int(remaining.rounded(.up)))S")
                    .font(.cluck(17 * scale))
                    .foregroundStyle(AppPalette.brown)
                    .monospacedDigit()
            }
        }
    }

    private func meter(fill: Double, colors: [Color]) -> some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(AppPalette.ticketHighlight)

            Capsule()
                .fill(
                    LinearGradient(
                        colors: colors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 180 * scale * fill, height: 24 * scale)
                .frame(width: 180 * scale, alignment: .leading)
        }
    }

    private var coinCounter: some View {
        ZStack(alignment: .top) {
            Image("HUDCoin")
                .resizable()
                .scaledToFit()
                .frame(width: 44 * scale, height: 44 * scale)
            Text("\(snapshot.coins)")
                .font(.cluck(16 * scale))
                .foregroundStyle(AppPalette.brown)
                .monospacedDigit()
                .padding(.top, 32 * scale)
        }
        .frame(width: 44 * scale, height: 51 * scale)
    }

    private var powerUpRow: some View {
        HStack(spacing: 10 * scale) {
            ForEach(snapshot.powerUps) { active in
                PowerUpChip(active: active)
                    .scaleEffect(scale)
                    .frame(width: 46 * scale, height: 46 * scale)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.18), value: snapshot.powerUps.map(\.id))
        .frame(height: 46 * scale)
    }
}
