@MainActor
protocol JetGameSceneEvents: AnyObject {
    func sceneDidStart()
    func sceneDidUpdate(_ snapshot: GameRunSnapshot)
    func sceneDidFinish(stats: GameRunStats)
}
