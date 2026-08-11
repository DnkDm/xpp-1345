import SwiftUI

struct LockGlyph: View {
    var color = AppPalette.brown

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let bodyHeight = height * 0.56
            let radius = width * 0.3

            ZStack(alignment: .bottom) {
                Path { path in
                    path.addArc(
                        center: CGPoint(x: width / 2, y: height - bodyHeight - radius * 0.2),
                        radius: radius,
                        startAngle: .degrees(180),
                        endAngle: .degrees(0),
                        clockwise: false
                    )
                }
                .stroke(color, style: StrokeStyle(lineWidth: width * 0.16, lineCap: .round))

                RoundedRectangle(cornerRadius: width * 0.18)
                    .fill(color)
                    .frame(height: bodyHeight)
            }
        }
    }
}
