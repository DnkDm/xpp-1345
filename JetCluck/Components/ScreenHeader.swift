import SwiftUI

struct ScreenHeader: View {
    private static let scale = DeviceLayout.chromeScale
    static let height: CGFloat = 112 * scale

    let title: String
    let coins: Int?
    let onBack: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                AppPalette.ticketHighlight
                    .frame(height: Self.height)

                Button {
                    onBack()
                    AudioManager.shared.play(.button)
                } label: {
                    Image("HomeButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44 * Self.scale, height: 44 * Self.scale)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(width: 44 * Self.scale, height: 44 * Self.scale)
                .position(x: 46 * Self.scale, y: 68 * Self.scale)
                .accessibilityLabel("Home")

                if let coins {
                    CoinBadge(value: coins)
                        .scaleEffect(Self.scale)
                        .position(
                            x: proxy.size.width - 95.5 * Self.scale,
                            y: 68 * Self.scale
                        )
                }
            }
            .frame(height: Self.height, alignment: .top)
        }
        .frame(height: Self.height)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .accessibilityElement(children: .contain)
    }
}
