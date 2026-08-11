import SwiftUI

struct ChickenAvatar: View {
    let skin: ChickenSkin

    var body: some View {
        Image(skin.assetName)
            .resizable()
            .scaledToFit()
    }
}
