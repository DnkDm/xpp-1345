import SwiftUI

struct StoryView: View {
    let onComplete: () -> Void
    @State private var page = 0

    /// Every story panel is authored 768x1344.
    private static let panelAspect: CGFloat = 768 / 1344

    private let pages = [
        ("Story1", "One day, trouble came\nto the farm..."),
        ("Story2", "Birds and drones attacked.\nShe didn't want to be dinner."),
        ("Story3", "She found an old jetpack in the barn.\nPut it on - and took off!"),
        ("Story4", "Now she flies, collects fuel\nand coins. Help her survive!")
    ]

    var body: some View {
        GeometryReader { proxy in
            let panel = panelSize(in: proxy.size)

            VStack(spacing: 18) {
                Image(pages[page].0)
                    .resizable()
                    .scaledToFill()
                    .frame(width: panel.width, height: panel.height)
                    .clipped()
                    .overlay(Rectangle().stroke(.black, lineWidth: 4))

                Text(pages[page].1.uppercased())
                    .font(.cluck(DeviceLayout.isPad ? 22 : 16))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .frame(maxWidth: max(360, panel.width))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                if page == pages.count - 1 {
                    onComplete()
                } else {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        page += 1
                    }
                }
            }
            .overlay(alignment: .topTrailing) {
                Button("SKIP", action: onComplete)
                    .font(.cluck(DeviceLayout.isPad ? 17 : 13))
                    .foregroundStyle(AppPalette.brown)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(AppPalette.ticket))
                    .padding(18)
            }
        }
        .background(Color.white)
    }

    /// The phone keeps its original framing; iPad shows the whole panel
    /// instead of a cropped vertical slice of it.
    private func panelSize(in size: CGSize) -> CGSize {
        guard DeviceLayout.isPad else {
            return CGSize(
                width: min(size.width - 48, 390),
                height: max(440, size.height - 150)
            )
        }

        let height = min(size.height - 170, (size.width - 96) / Self.panelAspect)
        return CGSize(width: height * Self.panelAspect, height: height)
    }
}
