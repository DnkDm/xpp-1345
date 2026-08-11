import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            SkyBackground()
            ScaledDesignCanvas {
                VStack(spacing: 8) {
                    Image("Chicken")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 210, height: 210)
                    Text("Jet Cluck: Time")
                        .font(.cluck(36))
                        .foregroundStyle(.white)
                }
            }
        }
    }
}
