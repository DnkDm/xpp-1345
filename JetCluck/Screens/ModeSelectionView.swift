import SwiftUI

struct ModeSelectionView: View {
    @ObservedObject var progress: ProgressStore
    let onBack: () -> Void
    let onPlay: (GameMode) -> Void

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
                        // On iPad the cards no longer fill the screen, so they
                        // sit in the middle instead of hugging the header.
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
                title: "Choose Flight",
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
            ForEach(GameMode.allCases) { mode in
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
            ForEach(GameMode.allCases) { mode in
                card(for: mode)
            }
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: 900)
    }

    private func card(for mode: GameMode) -> some View {
        ModeCard(
            mode: mode,
            best: progress.best(mode),
            isUnlocked: progress.isUnlocked(mode),
            unlock: progress.unlockProgress(for: mode),
            action: { onPlay(mode) }
        )
    }
}
