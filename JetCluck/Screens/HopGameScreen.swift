import SpriteKit
import SwiftUI

struct HopGameScreen: View {
    let mode: HopMode
    @ObservedObject var progress: ProgressStore
    let onHome: () -> Void
    @StateObject private var session: HopSession
    @State private var bestBeforeRun = 0
    @State private var isNewBest = false

    init(mode: HopMode, progress: ProgressStore, onHome: @escaping () -> Void) {
        self.mode = mode
        self.progress = progress
        self.onHome = onHome
        _session = StateObject(
            wrappedValue: HopSession(
                mode: mode,
                skinAssetName: progress.selectedSkin.assetName
            )
        )
    }

    var body: some View {
        ZStack {
            AppPalette.sky
                .ignoresSafeArea()

            SpriteView(scene: session.scene, options: [.ignoresSiblingOrder])
                .id(session.sceneID)
                .ignoresSafeArea()

            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { session.steer(translation: $0.translation.width) }
                        .onEnded { _ in session.endSteer() }
                )

            VStack {
                HopHUD(hud: session.hud, onPause: session.pause)
                Spacer()
                if session.state == .ready {
                    Text(mode.hint)
                        .font(.cluck(24))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .shadow(color: AppPalette.brown, radius: 0, x: 2, y: 3)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 90)
                }
            }

            if session.state == .paused {
                PauseOverlay(
                    onResume: session.resume,
                    onRestart: restart,
                    onHome: {
                        session.stop()
                        onHome()
                    }
                )
            }

            if session.state == .finished, let stats = session.result {
                ResultOverlay(
                    sky: AppPalette.sky,
                    title: stats.outcome.title,
                    coins: stats.coins,
                    scoreTitle: "Height",
                    score: stats.height,
                    bestTitle: "\(mode.title) best",
                    best: max(bestBeforeRun, stats.height),
                    unit: "M",
                    isNewBest: isNewBest,
                    onRestart: restart,
                    onHome: onHome
                )
            }
        }
        .onAppear {
            bestBeforeRun = progress.best(mode)
            session.onFinish = { stats in
                isNewBest = progress.isNewBest(mode: mode, stats: stats)
                bestBeforeRun = progress.best(mode)
                progress.finishHopRun(mode: mode, stats: stats)
            }
        }
        .onDisappear {
            session.stop()
        }
    }

    private func restart() {
        bestBeforeRun = progress.best(mode)
        isNewBest = false
        session.restart()
    }
}
