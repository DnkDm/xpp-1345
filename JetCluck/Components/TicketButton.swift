import SwiftUI

struct TicketButton: View {
    let title: String
    var compact = false
    let action: () -> Void

    private var buttonWidth: CGFloat { compact ? 270 : 238 }
    private var buttonHeight: CGFloat { compact ? 50 : 83 }
    private var horizontalTextPadding: CGFloat { compact ? 28 : 34 }

    var body: some View {
        Button {
            action()
            AudioManager.shared.play(.button)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppPalette.ticket)
                    .stroke(AppPalette.ticketHighlight, lineWidth: 2)
                    .shadow(color: AppPalette.ticketShadow, radius: 0, y: compact ? 5 : 8)
                    .padding(.horizontal, compact ? 0 : 8)

                if !compact {
                    HStack {
                        Image("TicketEdge")
                            .resizable()
                            .frame(width: 17, height: 65)
                        Spacer()
                        Image("TicketEdge")
                            .resizable()
                            .frame(width: 17, height: 65)
                    }
                }

                Text(title.uppercased())
                    .font(.cluck(compact ? 18 : 48))
                    .foregroundStyle(AppPalette.ticketHighlight)
                    .lineLimit(1)
                    .minimumScaleFactor(0.45)
                    .allowsTightening(true)
                    .frame(width: buttonWidth - horizontalTextPadding * 2)
                    .offset(y: 2)

                Text(title.uppercased())
                    .font(.cluck(compact ? 18 : 48))
                    .foregroundStyle(AppPalette.brown)
                    .lineLimit(1)
                    .minimumScaleFactor(0.45)
                    .allowsTightening(true)
                    .frame(width: buttonWidth - horizontalTextPadding * 2)
            }
            .frame(width: buttonWidth, height: buttonHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}
