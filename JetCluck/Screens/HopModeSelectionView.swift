import SwiftUI

struct HopModeSelectionView: View {
    @ObservedObject var progress: ProgressStore
    let onBack: () -> Void
    let onPlay: (HopMode) -> Void

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
                        .frame(
                            minHeight: DeviceLayout.isPad
                                ? proxy.size.height - ScreenHeader.height - 56
                                : 0,
                            alignment: .center
                        )

                        Color.clear.frame(height: 32)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .ignoresSafeArea()

            ScreenHeader(
                title: "Choose Climb",
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
        LazyVStack(spacing: 18) {
            ForEach(HopMode.allCases) { mode in
                card(for: mode)
            }
        }
    }

    /// iPad fits two cards side by side instead of a lonely centre column.
    private var grid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 340, maximum: 420), spacing: 20)],
            spacing: 20
        ) {
            ForEach(HopMode.allCases) { mode in
                card(for: mode)
            }
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: 900)
    }

    private func card(for mode: HopMode) -> some View {
        ModeCard(
            title: mode.title,
            tagline: mode.tagline,
            bestText: "Best: \(progress.best(mode)) m",
            playLabel: "Hop",
            isUnlocked: progress.isUnlocked(mode),
            requirement: mode.unlock.requirement,
            unlock: progress.unlockProgress(for: mode),
            action: { onPlay(mode) }
        ) {
            HopModeGlyph(mode: mode, skin: progress.selectedSkin)
        }
    }
}

/// Each climb is introduced by the thing that sets it apart: the chicken on a
/// cloud, an empty sky, a crossed-out jet can, a drone.
private struct HopModeGlyph: View {
    let mode: HopMode
    let skin: ChickenSkin

    var body: some View {
        switch mode {
        case .classic:
            SkyHopGlyph(skin: skin)
        case .cruise:
            CloudGlyph()
        case .pure:
            crossedOutCan
        case .storm:
            Image("DroneObstacle")
                .resizable()
                .scaledToFit()
        }
    }

    /// The same struck-through mark the menu uses for a switched-off setting.
    private var crossedOutCan: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)

            Image("Fuel")
                .resizable()
                .scaledToFit()
                .frame(width: proxy.size.width, height: proxy.size.height)
                .overlay {
                    Capsule()
                        .fill(AppPalette.brown)
                        .frame(width: side * 0.94, height: side * 0.11)
                        .rotationEffect(.degrees(-45))
                }
        }
    }
}
