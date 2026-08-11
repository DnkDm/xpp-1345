import AVFoundation
import Combine

@MainActor
final class AudioManager: NSObject, ObservableObject {
    enum Effect: String, CaseIterable {
        case button = "sfx_button"
        case coin = "sfx_coin"
        case fuel = "sfx_fuel"
        case hit = "sfx_hit"
    }

    static let shared = AudioManager()

    private var musicPlayer: AVAudioPlayer?
    private var effectPlayers: [Effect: AVAudioPlayer] = [:]
    private var missingFiles: Set<String> = []
    private var appIsActive = true
    private var musicEnabled = true
    private var soundEnabled = true

    private override init() {
        super.init()
        configureSession()
    }

    func updateSettings(musicEnabled: Bool, soundEnabled: Bool) {
        self.musicEnabled = musicEnabled
        self.soundEnabled = soundEnabled

        if musicEnabled, appIsActive {
            playMusic()
        } else {
            musicPlayer?.pause()
        }

        if !soundEnabled {
            stopAllEffects()
        }
    }

    func setAppActive(_ isActive: Bool) {
        appIsActive = isActive
        if isActive {
            if musicEnabled {
                playMusic()
            }
        } else {
            musicPlayer?.pause()
            stopAllEffects()
        }
    }

    func play(_ effect: Effect) {
        guard soundEnabled, appIsActive else { return }
        guard let player = effectPlayer(for: effect) else { return }
        player.currentTime = 0
        player.play()
    }

    func stop(_ effect: Effect) {
        guard let player = effectPlayers[effect] else { return }
        player.stop()
        player.currentTime = 0
    }

    func stopAllEffects() {
        effectPlayers.values.forEach {
            $0.stop()
            $0.currentTime = 0
        }
    }

    private func playMusic() {
        if musicPlayer == nil {
            musicPlayer = makePlayer(name: "music_main", extension: "mp3", loops: true)
            musicPlayer?.volume = 0.42
        }
        musicPlayer?.play()
    }

    private func effectPlayer(for effect: Effect) -> AVAudioPlayer? {
        if let player = effectPlayers[effect] {
            return player
        }
        guard let player = makePlayer(name: effect.rawValue, extension: "mp3", loops: false) else {
            return nil
        }
        player.volume = 0.72
        effectPlayers[effect] = player
        return player
    }

    private func makePlayer(name: String, extension fileExtension: String, loops: Bool) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: fileExtension) else {
            reportMissingFile("\(name).\(fileExtension)")
            return nil
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = loops ? -1 : 0
            player.prepareToPlay()
            return player
        } catch {
            print("JetCluck audio error for \(name).\(fileExtension): \(error.localizedDescription)")
            return nil
        }
    }

    private func reportMissingFile(_ filename: String) {
        guard missingFiles.insert(filename).inserted else { return }
        print("JetCluck audio file is missing: \(filename)")
    }

    private func configureSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("JetCluck audio session error: \(error.localizedDescription)")
        }
    }
}
