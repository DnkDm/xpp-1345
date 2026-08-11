import SwiftUI

struct CoinBadge: View {
    let value: Int

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(AppPalette.brown)
                .frame(width: 119, height: 44)
                .offset(x: 24)
            Image("Coin")
                .resizable()
                .scaledToFit()
                .frame(width: 68, height: 68)
            Text("\(value)")
                .font(.cluck(24))
                .foregroundStyle(AppPalette.ticketHighlight)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.55)
                .frame(width: 75)
                .offset(x: 68)
        }
        .frame(width: 143, height: 68)
    }
}
