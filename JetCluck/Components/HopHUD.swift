import SwiftUI

struct HopHUD: View {
    @ObservedObject var hud: HopHUDModel
    let onPause: () -> Void

    private let scale = DeviceLayout.chromeScale
    private var snapshot: HopRunSnapshot { hud.snapshot }

    var body: some View {
        GeometryReader { proxy in
            let midX = proxy.size.width / 2

            ZStack(alignment: .topLeading) {
                pauseButton
                    .position(x: 46 * scale, y: 106 * scale)

                coinCounter
                    .position(x: proxy.size.width - 46 * scale, y: 109.5 * scale)

                heightReadout
                    .position(x: midX, y: 160 * scale)

                if let boost = snapshot.boost {
                    boostChip(fraction: boost)
                        .position(x: midX, y: 226 * scale)
                }
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

    /// The sky darkens as the climb goes on, so the height sits on a ticket
    /// instead of straight on the background.
    private var heightReadout: some View {
        HStack(alignment: .firstTextBaseline, spacing: 5 * scale) {
            Text("\(snapshot.height)")
                .font(.cluck(40 * scale))
                .monospacedDigit()
            Text("M")
                .font(.cluck(20 * scale))
        }
        .foregroundStyle(AppPalette.brown)
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .padding(.horizontal, 22 * scale)
        .frame(height: 54 * scale)
        .background(
            Capsule()
                .fill(AppPalette.ticketHighlight)
                .stroke(AppPalette.brown, lineWidth: 3 * scale)
        )
        .accessibilityLabel("Height \(snapshot.height) metres")
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
                .shadow(color: .white.opacity(0.9), radius: 2 * scale)
                .padding(.top, 32 * scale)
        }
        .frame(width: 44 * scale, height: 51 * scale)
    }

    private func boostChip(fraction: Double) -> some View {
        ZStack {
            Circle()
                .fill(AppPalette.ticket)
                .overlay(Circle().stroke(AppPalette.brown, lineWidth: 3))
                .frame(width: 38, height: 38)

            Image("Fuel")
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)

            Circle()
                .stroke(AppPalette.brown.opacity(0.22), lineWidth: 4)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(
                    AppPalette.brown,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 46, height: 46)
        .scaleEffect(scale)
        .frame(width: 46 * scale, height: 46 * scale)
        .accessibilityLabel("Jet boost")
    }
}
