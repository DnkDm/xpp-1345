import SwiftUI

struct ShopView: View {
    @ObservedObject var progress: ProgressStore
    let onBack: () -> Void
    @State private var index = 0

    private var skin: ChickenSkin { ChickenSkin.all[index] }

    var body: some View {
        ZStack {
            SkyBackground()
            ScaledDesignCanvas {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 300)
                    Text("\(index + 1) / \(ChickenSkin.all.count)")
                        .font(.cluck(16))
                        .foregroundStyle(AppPalette.brown.opacity(0.75))
                        .monospacedDigit()
                    Color.clear.frame(height: 12)
                    HStack(spacing: 16) {
                        arrow(delta: -1)
                        ChickenAvatar(skin: skin)
                            .frame(width: 198, height: 198)
                        arrow(delta: 1)
                    }
                    Color.clear.frame(height: 14)
                    Text(skin.name.uppercased())
                        .font(.cluck(28))
                        .foregroundStyle(AppPalette.brown)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Color.clear.frame(height: 10)
                    priceView
                    Color.clear.frame(height: 16)
                    TicketButton(
                        title: buttonTitle,
                        action: { progress.buyOrSelect(skin) }
                    )
                    .disabled(!canBuy)
                    .opacity(canBuy ? 1 : 0.55)
                    Spacer()
                }
            }

            ScreenHeader(title: "Shop", coins: progress.coins, onBack: onBack)
                .frame(height: ScreenHeader.height)
                .frame(maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea()
                .zIndex(100)
        }
        .onAppear {
            index = ChickenSkin.all.firstIndex { $0.id == progress.selectedSkinID } ?? 0
        }
    }

    private var buttonTitle: String {
        if progress.selectedSkinID == skin.id { return "Selected" }
        if progress.unlockedSkinIDs.contains(skin.id) { return "Select" }
        return "Buy"
    }

    private var canBuy: Bool {
        progress.unlockedSkinIDs.contains(skin.id) || progress.coins >= skin.price
    }

    @ViewBuilder
    private var priceView: some View {
        if progress.unlockedSkinIDs.contains(skin.id) {
            Text("OWNED")
                .font(.cluck(22))
                .foregroundStyle(AppPalette.green)
                .frame(height: 30)
        } else {
            HStack(spacing: 6) {
                Image("Coin").resizable().scaledToFit().frame(width: 30, height: 30)
                Text("\(skin.price)")
                    .font(.cluck(22))
                    .foregroundStyle(AppPalette.brown)
            }
            .frame(height: 30)
        }
    }

    private func arrow(delta: Int) -> some View {
        Button {
            index = (index + delta + ChickenSkin.all.count) % ChickenSkin.all.count
            AudioManager.shared.play(.button)
        } label: {
            Image("ArrowIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
                .rotationEffect(delta < 0 ? .degrees(180) : .zero)
        }
        .buttonStyle(.plain)
    }
}
