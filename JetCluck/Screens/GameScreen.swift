import SpriteKit
import SwiftUI

struct GameScreen: View {
    let mode: GameMode
    @ObservedObject var progress: ProgressStore
    let onHome: () -> Void
    @StateObject private var session: GameSession
    @State private var bestBeforeRun = 0
    @State private var isNewBest = false

    init(mode: GameMode, progress: ProgressStore, onHome: @escaping () -> Void) {
        self.mode = mode
        self.progress = progress
        self.onHome = onHome
        _session = StateObject(
            wrappedValue: GameSession(
                mode: mode,
                skinAssetName: progress.selectedSkin.assetName
            )
        )
    }

    private var sky: Color { Color(hex: mode.config.skyHex) }

    var body: some View {
        ZStack {
            sky
                .ignoresSafeArea()

            SpriteView(scene: session.scene, options: [.ignoresSiblingOrder])
                .id(session.sceneID)
                .background(sky)
                .ignoresSafeArea()

            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in session.setThrusting(true) }
                        .onEnded { _ in session.setThrusting(false) }
                )

            VStack {
                GameHUD(hud: session.hud, onPause: session.pause)
                Spacer()
                if session.state == .ready {
                    Text(mode.hint)
                        .font(.cluck(24))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .shadow(color: AppPalette.brown, radius: 0, x: 2, y: 3)
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
                    mode: mode,
                    stats: stats,
                    best: bestBeforeRun,
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
                progress.finishGame(mode: mode, stats: stats)
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
