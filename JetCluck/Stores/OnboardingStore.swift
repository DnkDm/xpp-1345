import Combine
import Foundation

@MainActor
final class OnboardingStore: ObservableObject {
    @Published private(set) var hasSeenStory: Bool

    private let defaultsKey = "hasSeenStory"
    private let markerURL: URL

    init(
        defaults: UserDefaults = .standard,
        fileManager: FileManager = .default
    ) {
        let supportURL = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]
        markerURL = supportURL.appendingPathComponent(
            "jetcluck-installation.marker",
            isDirectory: false
        )

        if fileManager.fileExists(atPath: markerURL.path) {
            hasSeenStory = defaults.bool(forKey: defaultsKey)
        } else {
            hasSeenStory = false
            defaults.set(false, forKey: defaultsKey)
            try? fileManager.createDirectory(
                at: supportURL,
                withIntermediateDirectories: true
            )
            fileManager.createFile(atPath: markerURL.path, contents: Data())
        }
    }

    func completeStory() {
        hasSeenStory = true
        UserDefaults.standard.set(true, forKey: defaultsKey)
    }
}
