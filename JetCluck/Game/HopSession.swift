import Combine
import CoreGraphics
import Foundation
import SpriteKit

@MainActor
final class HopSession: ObservableObject, HopGameSceneEvents {
    @Published private(set) var state: GameRunState = .ready
    @Published private(set) var sceneID = UUID()
    @Published private(set) var result: HopRunStats?

    let mode: HopMode
    let hud = HopHUDModel()
    private(set) var scene: HopGameScene
    var onFinish: ((HopRunStats) -> Void)?

    private let skinAssetName: String
    /// Drag gives a running total, the scene wants the step since last time.
    private var lastSteerTranslation: CGFloat = 0

    init(mode: HopMode, skinAssetName: String) {
        self.mode = mode
        self.skinAssetName = skinAssetName
        let scene = HopGameScene(
            size: CGSize(width: 390, height: 844),
            mode: mode,
            skinAssetName: skinAssetName
        )
        scene.scaleMode = .resizeFill
        self.scene = scene
        scene.eventSink = self
    }

    func steer(translation: CGFloat) {
        guard state == .ready || state == .playing else { return }
        if state == .ready {
            lastSteerTranslation = translation
            scene.start()
            return
        }
        scene.steer(by: translation - lastSteerTranslation)
        lastSteerTranslation = translation
    }

    func endSteer() {
        lastSteerTranslation = 0
    }

    func pause() {
        guard state == .playing else { return }
        state = .paused
        scene.isPaused = true
    }

    func resume() {
        guard state == .paused else { return }
        scene.isPaused = false
        state = .playing
    }

    func restart() {
        AudioManager.shared.stopAllEffects()
        scene.isPaused = false
        scene.eventSink = nil
        let replacement = HopGameScene(
            size: scene.size,
            mode: mode,
            skinAssetName: skinAssetName
        )
        replacement.scaleMode = .resizeFill
        replacement.eventSink = self
        scene = replacement
        sceneID = UUID()
        state = .ready
        result = nil
        lastSteerTranslation = 0
        hud.reset()
        objectWillChange.send()
    }

    func stop() {
        AudioManager.shared.stopAllEffects()
        scene.isPaused = true
        scene.eventSink = nil
    }

    func hopSceneDidStart() {
        state = .playing
    }

    func hopSceneDidUpdate(_ snapshot: HopRunSnapshot) {
        hud.apply(snapshot)
    }

    func hopSceneDidFinish(stats: HopRunStats) {
        guard state != .finished else { return }
        result = stats
        state = .finished
        onFinish?(stats)
    }
}
