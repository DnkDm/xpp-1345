import SwiftUI

struct FigmaImageButton: View {
    let assetName: String
    let size: CGSize
    var isOn = true
    let action: () -> Void

    var body: some View {
        Button {
            action()
            AudioManager.shared.play(.button)
        } label: {
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: size.width, height: size.height)
                .overlay {
                    if !isOn {
                        Rectangle()
                            .fill(AppPalette.brown)
                            .frame(width: size.width * 0.62, height: 4)
                            .rotationEffect(.degrees(-45))
                    }
                }
        }
        .buttonStyle(.plain)
    }
}
