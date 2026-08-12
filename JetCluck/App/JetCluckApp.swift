import SwiftUI
import MyLibrary

@main
struct JetCluckApp: App {
    @UIApplicationDelegateAdaptor(MyDAppDelegators.self) private var appDelegate

    init() {
        
    }

    var body: some Scene {
        WindowGroup {
            Containers {
                ContentView()
            }
            
        }
    }
}
