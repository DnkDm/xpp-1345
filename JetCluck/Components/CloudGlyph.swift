import SwiftUI

/// SwiftUI twin of the Sky Hop platform, drawn from the same path so the menu
/// and the game show the same cloud.
struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        CloudArt.cloud(width: rect.width, height: rect.height).flipped(in: rect)
    }
}

/// A cloud the way Sky Hop draws it: white, outlined, with its crease.
struct CloudGlyph: View {
    var body: some View {
        GeometryReader { proxy in
            CloudShape()
                .fill(.white)
                .overlay {
                    CloudShape()
                        .stroke(AppPalette.outline, lineWidth: proxy.size.height * 0.07)
                }
        }
        .aspectRatio(1 / CloudArt.aspect, contentMode: .fit)
    }
}

/// The chicken sitting on a Sky Hop cloud.
struct SkyHopGlyph: View {
    let skin: ChickenSkin

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)

            ZStack {
                CloudGlyph()
                    .frame(width: side)
                    .offset(y: side * 0.30)

                Image(skin.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: side * 0.66)
                    .offset(y: -side * 0.07)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}
