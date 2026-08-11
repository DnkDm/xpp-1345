import SwiftUI

struct QuestsView: View {
    @ObservedObject var progress: ProgressStore
    let onBack: () -> Void

    var body: some View {
        ZStack {
            AppPalette.ticketHighlight
                .ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 20) {
                    Color.clear.frame(height: ScreenHeader.height)

                    StatsPanel(progress: progress)
                        .padding(.horizontal, 24)

                    LazyVStack(spacing: 0) {
                        ForEach(ProgressStore.quests) { quest in
                            QuestRow(quest: quest, progress: progress)
                        }
                    }
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppPalette.brown)
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
                .frame(maxWidth: DeviceLayout.maxContentWidth)
                .frame(maxWidth: .infinity)
            }
            .ignoresSafeArea()
            .scrollIndicators(.hidden)

            ScreenHeader(title: "Tasks", coins: progress.coins, onBack: onBack)
                .frame(height: ScreenHeader.height)
                .frame(maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea()
                .zIndex(100)
        }
    }
}
