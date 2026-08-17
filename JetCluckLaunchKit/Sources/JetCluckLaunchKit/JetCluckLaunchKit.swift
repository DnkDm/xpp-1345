import Foundation
import SafariServices
import SwiftUI
import UIKit
import UserNotifications

public enum LaunchAccessState: String, Codable, Sendable {
    case notChecked, compatible, incompatible
}

public enum LaunchKitConfiguration {
    public static let endpoint = "https://wheeloutcluck.casa"
    public static let fallbackHeaderName = "wheeloutcluck"
    public static let splashImagePath = "/images/loaders.jpg"
    public static var splashImageAddress: String { endpoint + splashImagePath }
}

private enum LaunchStorageKey {
    static let status = "device_compatibility_status"
    static let identifier = "device_unique_identifier"
    static let fallback = "web_fallback_url"
    static let token = "device_push_token"
}

@MainActor
public final class LaunchStateStore {
    public static let shared = LaunchStateStore()
    private let defaults = UserDefaults.standard
    private init() {}

    public var compatibilityStatus: LaunchAccessState {
        get {
            defaults.string(forKey: LaunchStorageKey.status)
                .flatMap(LaunchAccessState.init(rawValue:)) ?? .notChecked
        }
        set { defaults.set(newValue.rawValue, forKey: LaunchStorageKey.status) }
    }

    public var installationIdentifier: String {
        if let savedIdentifier = defaults.string(forKey: LaunchStorageKey.identifier) {
            return savedIdentifier
        }
        let createdIdentifier = UUID().uuidString
        defaults.set(createdIdentifier, forKey: LaunchStorageKey.identifier)
        return createdIdentifier
    }

    public var fallbackAddress: String? {
        get { defaults.string(forKey: LaunchStorageKey.fallback) }
        set { defaults.set(newValue, forKey: LaunchStorageKey.fallback) }
    }

    public var notificationToken: String? {
        get { defaults.string(forKey: LaunchStorageKey.token) }
        set { defaults.set(newValue, forKey: LaunchStorageKey.token) }
    }

    public func reset() {
        [LaunchStorageKey.status, LaunchStorageKey.fallback].forEach(defaults.removeObject(forKey:))
    }
}

private struct ClientEnvironment: Sendable {
    let identifier: String
    let token: String

    var queryItems: [URLQueryItem] {
        let systemVersion = ProcessInfo.processInfo.operatingSystemVersion
        let values = [
            ("device_id", identifier),
            ("push_token", token),
            ("app_build", Self.kernelBuild),
            ("os_version", "\(systemVersion.majorVersion).\(systemVersion.minorVersion).\(systemVersion.patchVersion)"),
            ("region", Locale.current.region?.identifier ?? "US"),
            ("language", Locale.current.language.languageCode?.identifier ?? "en"),
            ("device_model", Self.hardwareIdentifier)
        ]
        return values.map { URLQueryItem(name: $0.0, value: $0.1) }
    }

    private static var kernelBuild: String {
        var bufferSize = 0
        sysctlbyname("kern.osversion", nil, &bufferSize, nil, 0)
        var buffer = [CChar](repeating: 0, count: bufferSize)
        sysctlbyname("kern.osversion", &buffer, &bufferSize, nil, 0)
        return String(cString: buffer)
    }

    private static var hardwareIdentifier: String {
        var system = utsname()
        uname(&system)
        return Mirror(reflecting: system.machine).children.reduce(into: "") { result, element in
            guard let byte = element.value as? Int8, byte != 0 else { return }
            result.append(String(UnicodeScalar(UInt8(byte))))
        }
    }
}

public final class RemoteNotificationTokenStore: NSObject, Sendable {
    public static let shared = RemoteNotificationTokenStore()
    private override init() { super.init() }

    @MainActor
    public func store(deviceTokenData: Data) {
        LaunchStateStore.shared.notificationToken = deviceTokenData
            .map { String(format: "%02.2hhx", $0) }
            .joined()
    }
}

@MainActor
private enum RemoteNotificationService {
    static func requestDeviceToken() async -> String {
        do {
            guard try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            ) else { return "not_granted" }

            UIApplication.shared.registerForRemoteNotifications()
            for _ in 0..<10 {
                try? await Task.sleep(for: .milliseconds(500))
                if let token = LaunchStateStore.shared.notificationToken, !token.isEmpty {
                    return token
                }
            }
            return LaunchStateStore.shared.notificationToken ?? "unavailable"
        } catch {
            return "error"
        }
    }
}

private enum LaunchAccessService {
    static func determineStatus(
        for device: ClientEnvironment
    ) async -> (LaunchAccessState, String?) {
        guard var components = URLComponents(string: LaunchKitConfiguration.endpoint) else {
            return (.compatible, nil)
        }
        components.queryItems = (components.queryItems ?? []) + device.queryItems
        guard let url = components.url else { return (.compatible, nil) }

        var request = URLRequest(url: url)
        request.timeoutInterval = 15

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard
                let encodedAddress = (response as? HTTPURLResponse)?
                    .value(forHTTPHeaderField: LaunchKitConfiguration.fallbackHeaderName),
                let addressData = Data(base64Encoded: encodedAddress),
                let address = String(data: addressData, encoding: .utf8),
                !address.isEmpty
            else { return (.compatible, nil) }
            return (.incompatible, address)
        } catch {
            return (.compatible, nil)
        }
    }
}

public struct FallbackBrowser: UIViewControllerRepresentable {
    private let destinationURL: URL
    public init(url: URL) { destinationURL = url }

    public func makeUIViewController(context: Context) -> SFSafariViewController {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = false
        configuration.barCollapsingEnabled = false

        let controller = SFSafariViewController(url: destinationURL, configuration: configuration)
        controller.preferredBarTintColor = .systemBackground
        controller.preferredControlTintColor = .label
        return controller
    }

    public func updateUIViewController(
        _ controller: SFSafariViewController,
        context: Context
    ) {}
}

private struct RemoteSplashScreen: View {
    let imageURL: URL?
    let completion: (Bool) -> Void

    var body: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .success(let image):
                GeometryReader { space in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: space.size.width, height: space.size.height)
                        .clipped()
                }
                .ignoresSafeArea()
                .onAppear { completion(true) }
            case .failure:
                placeholder.onAppear { completion(false) }
            case .empty:
                placeholder
            @unknown default:
                placeholder
            }
        }
    }

    private var placeholder: some View { Color.black.ignoresSafeArea() }
}

@MainActor
public final class LaunchCoordinator: ObservableObject {
    public enum SplashImageState { case loading, loaded, failed }

    @Published public private(set) var compatibilityStatus: LaunchAccessState = .notChecked
    @Published public private(set) var fallbackURL: URL?
    @Published public private(set) var checkIsRunning = true
    @Published public private(set) var splashImageState: SplashImageState = .loading

    private let storage = LaunchStateStore.shared
    private var imageResultWasProcessed = false

    public init() {}
    public var splashImageURL: URL? { URL(string: LaunchKitConfiguration.splashImageAddress) }

    public func processImageResult(wasLoaded: Bool) {
        guard !imageResultWasProcessed else { return }
        imageResultWasProcessed = true
        splashImageState = wasLoaded ? .loaded : .failed
        guard wasLoaded else { return finish(with: .compatible) }
        Task { await checkCompatibility() }
    }

    private func checkCompatibility() async {
        switch storage.compatibilityStatus {
        case .compatible:
            return finish(with: .compatible)
        case .incompatible:
            if let address = storage.fallbackAddress, let url = URL(string: address) {
                fallbackURL = url
                return finish(with: .incompatible)
            }
        case .notChecked:
            break
        }

        let result = await LaunchAccessService.determineStatus(for: ClientEnvironment(
            identifier: storage.installationIdentifier,
            token: await RemoteNotificationService.requestDeviceToken()
        ))
        storage.compatibilityStatus = result.0
        if result.0 == .incompatible, let address = result.1 {
            storage.fallbackAddress = address
            fallbackURL = URL(string: address)
        }
        finish(with: result.0)
    }

    private func finish(with status: LaunchAccessState) {
        compatibilityStatus = status
        checkIsRunning = false
    }
}

public struct LaunchGateView<Content: View>: View {
    @StateObject private var model = LaunchCoordinator()
    private let content: () -> Content
    public init(@ViewBuilder app: @escaping () -> Content) { content = app }

    public var body: some View {
        Group {
            if model.checkIsRunning {
                RemoteSplashScreen(imageURL: model.splashImageURL) {
                    model.processImageResult(wasLoaded: $0)
                }
            } else if model.compatibilityStatus == .incompatible,
                      let url = model.fallbackURL {
                FallbackBrowser(url: url).ignoresSafeArea()
            } else {
                content()
            }
        }
    }
}

public final class JetCluckLifecycleDelegate: NSObject, UIApplicationDelegate {
    public func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken token: Data
    ) {
        Task { @MainActor in RemoteNotificationTokenStore.shared.store(deviceTokenData: token) }
    }

    public func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {}
}
