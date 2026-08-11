import SwiftUI

struct QuestRow: View {
    let quest: Quest
    @ObservedObject var progress: ProgressStore

    var body: some View {
        let value = progress.progress(for: quest)
        let complete = value >= quest.goal
        let claimed = progress.claimedQuestIDs.contains(quest.id)

        Button {
            if complete && !claimed {
                progress.claim(quest)
            }
        } label: {
            HStack(spacing: 18) {
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(claimed ? Color(hex: "0CA46D") : AppPalette.ticket)
                        .frame(width: 60, height: 60)
                    Image("Coin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .padding(.top, 8)
                    Text("\(quest.reward)")
                        .font(.cluck(16))
                        .foregroundStyle(AppPalette.ticketHighlight)
                        .padding(.top, 40)
                }
                .frame(width: 60, height: 60)

                Text(quest.title.uppercased())
                    .font(.cluck(16))
                    .foregroundStyle(AppPalette.ticketHighlight)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.62)

                Spacer(minLength: 0)

                status(value: value, complete: complete, claimed: claimed)
                    .frame(width: 78, alignment: .trailing)
            }
            .frame(height: 94)
            .padding(.horizontal, 24)
            .overlay(alignment: .bottom) {
                DashedDivider()
                    .padding(.horizontal, 24)
            }
        }
        .buttonStyle(.plain)
        .allowsHitTesting(complete && !claimed)
    }

    @ViewBuilder
    private func status(value: Int, complete: Bool, claimed: Bool) -> some View {
        if claimed {
            Text("DONE")
                .font(.cluck(15))
                .foregroundStyle(Color(hex: "6FE0AE"))
        } else if complete {
            Text("CLAIM")
                .font(.cluck(15))
                .foregroundStyle(AppPalette.brown)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(AppPalette.ticket))
        } else {
            VStack(alignment: .trailing, spacing: 5) {
                Text("\(value)/\(quest.goal)")
                    .font(.cluck(14))
                    .foregroundStyle(AppPalette.ticketHighlight.opacity(0.7))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                ProgressBar(fraction: Double(value) / Double(quest.goal))
                    .frame(width: 66, height: 8)
            }
        }
    }
}
