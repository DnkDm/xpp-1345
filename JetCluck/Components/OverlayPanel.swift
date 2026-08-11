import SwiftUI

struct OverlayPanel<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        Color.black.opacity(0.35)
            .ignoresSafeArea()
            .overlay {
                VStack(spacing: 16) {
                    Text(title.uppercased())
                        .font(.cluck(30))
                        .foregroundStyle(AppPalette.brown)
                    content
                }
                .padding(24)
                .frame(maxWidth: 310)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .stroke(AppPalette.brown, lineWidth: 4)
                )
                .scaleEffect(DeviceLayout.chromeScale)
            }
    }
}
