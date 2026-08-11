import SwiftUI

struct MainMenuView: View {
    @ObservedObject var progress: ProgressStore
    let onPlay: () -> Void
    let onQuests: () -> Void
    let onShop: () -> Void

    var body: some View {
        ZStack {
            SkyBackground()
            ScaledDesignCanvas {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 108)
                    ChickenAvatar(skin: progress.selectedSkin)
                        .frame(width: 198, height: 198)
                    Spacer().frame(height: 28)
                    VStack(spacing: 16) {
                        FigmaImageButton(
                            assetName: "MenuPlay",
                            size: CGSize(width: 238, height: 91),
                            action: onPlay
                        )
                        FigmaImageButton(
                            assetName: "MenuTasks",
                            size: CGSize(width: 238, height: 91),
                            action: onQuests
                        )
                        FigmaImageButton(
                            assetName: "MenuShop",
                            size: CGSize(width: 238, height: 91),
                            action: onShop
                        )
                    }
                    Color.clear.frame(height: 40)
                    HStack(spacing: 24) {
                        FigmaImageButton(
                            assetName: "MusicButton",
                            size: CGSize(width: 71, height: 75),
                            isOn: progress.musicEnabled,
                            action: { progress.musicEnabled.toggle() }
                        )
                        FigmaImageButton(
                            assetName: "SoundButton",
                            size: CGSize(width: 71, height: 75),
                            isOn: progress.soundEnabled,
                            action: { progress.soundEnabled.toggle() }
                        )
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
        }
    }
}
