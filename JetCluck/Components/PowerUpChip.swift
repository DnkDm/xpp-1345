import SwiftUI

struct PowerUpChip: View {
    let active: ActivePowerUp

    var body: some View {
        ZStack {
            Circle()
                .fill(AppPalette.ticket)
                .overlay(Circle().stroke(AppPalette.brown, lineWidth: 3))
                .frame(width: 38, height: 38)

            PowerUpGlyph(kind: active.kind)
                .frame(width: 22, height: 22)

            if let fraction = active.fraction {
                Circle()
                    .stroke(AppPalette.brown.opacity(0.22), lineWidth: 4)
                Circle()
                    .trim(from: 0, to: fraction)
                    .stroke(
                        AppPalette.brown,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }
        }
        .frame(width: 46, height: 46)
        .accessibilityLabel(active.kind.title)
    }
}
