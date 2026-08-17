@MainActor
protocol HopGameSceneEvents: AnyObject {
    func hopSceneDidStart()
    func hopSceneDidUpdate(_ snapshot: HopRunSnapshot)
    func hopSceneDidFinish(stats: HopRunStats)
}
