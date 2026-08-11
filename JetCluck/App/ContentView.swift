import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var progress = ProgressStore()
    @StateObject private var onboarding = OnboardingStore()
    @StateObject private var audio = AudioManager.shared
    @State private var route: AppRoute = .splash

    var body: some View {
        ZStack {
            switch route {
            case .splash:
                SplashView()
                    .task {
                        try? await Task.sleep(for: .seconds(1.1))
                        route = onboarding.hasSeenStory ? .menu : .story
                    }
            case .story:
                StoryView {
                    onboarding.completeStory()
                    route = .menu
                }
            case .menu:
                MainMenuView(
                    progress: progress,
                    onPlay: { route = .modeSelection },
                    onQuests: { route = .quests },
                    onShop: { route = .shop }
                )
            case .modeSelection:
                ModeSelectionView(
                    progress: progress,
                    onBack: { route = .menu },
                    onPlay: { route = .game($0) }
                )
            case .quests:
                QuestsView(progress: progress, onBack: { route = .menu })
            case .shop:
                ShopView(progress: progress, onBack: { route = .menu })
            case .game(let mode):
                GameScreen(
                    mode: mode,
                    progress: progress,
                    onHome: { route = .menu }
                )
                .id(mode)
            }
        }
        .preferredColorScheme(.light)
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
        .onAppear {
            audio.updateSettings(
                musicEnabled: progress.musicEnabled,
                soundEnabled: progress.soundEnabled
            )
        }
        .onChange(of: progress.musicEnabled) { _, enabled in
            audio.updateSettings(
                musicEnabled: enabled,
                soundEnabled: progress.soundEnabled
            )
        }
        .onChange(of: progress.soundEnabled) { _, enabled in
            audio.updateSettings(
                musicEnabled: progress.musicEnabled,
                soundEnabled: enabled
            )
        }
        .onChange(of: scenePhase) { _, phase in
            audio.setAppActive(phase == .active)
        }
    }
}

#Preview {
    ContentView()
}
