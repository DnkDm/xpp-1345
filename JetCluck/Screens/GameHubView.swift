import SwiftUI

/// Picks a game. Both cards show the player's own chicken, so the choice is
/// between two ways to play her rather than two unrelated apps.
struct GameHubView: View {
    @ObservedObject var progress: ProgressStore
    let onBack: () -> Void
    let onFlight: () -> Void
    let onSkyHop: () -> Void

    var body: some View {
        ZStack {
            SkyBackground()

            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: ScreenHeader.height + 12)

                        Group {
                            if DeviceLayout.isWide(proxy.size.width) {
                                grid
                            } else {
                                column
                            }
                        }
                        .frame(maxWidth: .infinity)
                        // Only two cards, so they sit in the middle of the sky
                        // instead of hanging off the header.
                        .frame(
                            minHeight: proxy.size.height - ScreenHeader.height - 56,
                            alignment: .center
                        )

                        Color.clear.frame(height: 32)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .ignoresSafeArea()

            ScreenHeader(
                title: "Choose Game",
                coins: progress.coins,
                onBack: onBack
            )
            .frame(height: ScreenHeader.height)
            .frame(maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea()
            .zIndex(100)
        }
    }

    private var column: some View {
        VStack(spacing: 18) {
            flightCard
            skyHopCard
        }
    }

    /// iPad fits both cards side by side instead of a lonely centre column.
    private var grid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 340, maximum: 420), spacing: 20)],
            spacing: 20
        ) {
            flightCard
            skyHopCard
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: 900)
    }

    private var flightCard: some View {
        GameHubCard(
            title: "Jetpack Flight",
            tagline: "Hold to fly. Five modes of fuel, traffic and night skies.",
            best: "Best flight: \(progress.bestFlightSeconds) sec",
            play: "Fly",
            action: onFlight
        ) {
            FlightGlyph(skin: progress.selectedSkin)
        }
    }

    private var skyHopCard: some View {
        GameHubCard(
            title: "Sky Hop",
            tagline: "Drag to steer. Four climbs, from a calm cruise to a storm.",
            best: "Best climb: \(progress.bestHopHeight) m",
            play: "Hop",
            action: onSkyHop
        ) {
            SkyHopGlyph(skin: progress.selectedSkin)
        }
    }
}

/// The chicken in mid-flight, with the speed streaks the game draws behind her.
private struct FlightGlyph: View {
    let skin: ChickenSkin

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)

            ZStack {
                VStack(alignment: .leading, spacing: side * 0.13) {
                    streak(width: side * 0.26)
                    streak(width: side * 0.17)
                }
                .frame(width: side, alignment: .leading)
                .offset(x: -side * 0.04, y: side * 0.06)

                Image(skin.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: side * 0.86)
                    .rotationEffect(.degrees(-10))
                    .offset(x: side * 0.06)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    private func streak(width: CGFloat) -> some View {
        Capsule()
            .fill(AppPalette.skyDark)
            .frame(width: width, height: max(3, width * 0.16))
    }
}
