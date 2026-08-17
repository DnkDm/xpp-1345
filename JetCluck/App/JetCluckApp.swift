import SwiftUI
import JetCluckLaunchKit

@main
struct JetCluckApp: App {
    @UIApplicationDelegateAdaptor(JetCluckLifecycleDelegate.self)
    private var lifecycleDelegate

    var body: some Scene {
        JetCluckWindowScene()
    }
}

private struct JetCluckWindowScene: Scene {
    var body: some Scene {
        WindowGroup {
            LaunchGateView {
                ContentView()
            }
        }
    }
}
