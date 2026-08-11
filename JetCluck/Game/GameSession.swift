import Combine
import CoreGraphics
import Foundation
import SpriteKit

@MainActor
final class GameSession: ObservableObject, JetGameSceneEvents {
    @Published private(set) var state: GameRunState = .ready
    @Published private(set) var sceneID = UUID()
    @Published private(set) var result: GameRunStats?

    let mode: GameMode
    let hud: HUDModel
    private(set) var scene: JetGameScene
    var onFinish: ((GameRunStats) -> Void)?

    private let skinAssetName: String

    init(mode: GameMode, skinAssetName: String) {
        self.mode = mode
        self.skinAssetName = skinAssetName
        self.hud = HUDModel(mode: mode)
        let scene = JetGameScene(
            size: CGSize(width: 390, height: 844),
            mode: mode,
            skinAssetName: skinAssetName
        )
        scene.scaleMode = .resizeFill
        self.scene = scene
        scene.eventSink = self
    }

    func setThrusting(_ isThrusting: Bool) {
        guard state == .ready || state == .playing else { return }
        if state == .ready {
            scene.start()
        }
        scene.isThrusting = isThrusting
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
        let replacement = JetGameScene(
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
        hud.reset()
        objectWillChange.send()
    }

    func stop() {
        AudioManager.shared.stopAllEffects()
        scene.isPaused = true
        scene.eventSink = nil
    }

    func sceneDidStart() {
        state = .playing
    }

    func sceneDidUpdate(_ snapshot: GameRunSnapshot) {
        hud.apply(snapshot)
    }

    func sceneDidFinish(stats: GameRunStats) {
        guard state != .finished else { return }
        result = stats
        state = .finished
        onFinish?(stats)
    }
}
