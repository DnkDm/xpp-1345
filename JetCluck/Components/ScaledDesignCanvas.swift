import SwiftUI

struct ScaledDesignCanvas<Content: View>: View {
    private let designSize: CGSize
    @ViewBuilder private let content: Content

    init(
        designSize: CGSize = CGSize(width: 390, height: 844),
        @ViewBuilder content: () -> Content
    ) {
        self.designSize = designSize
        self.content = content()
    }

    var body: some View {
        GeometryReader { proxy in
            let scale = min(
                proxy.size.width / designSize.width,
                proxy.size.height / designSize.height,
                DeviceLayout.maxCanvasScale
            )

            content
                .frame(width: designSize.width, height: designSize.height)
                .scaleEffect(scale)
                .frame(
                    width: proxy.size.width,
                    height: proxy.size.height,
                    alignment: .center
                )
        }
        .ignoresSafeArea()
    }
}
