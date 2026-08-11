import SwiftUI

struct SkyBackground: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                AppPalette.sky
                Image("Clouds")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
        }
        .ignoresSafeArea()
    }
}
