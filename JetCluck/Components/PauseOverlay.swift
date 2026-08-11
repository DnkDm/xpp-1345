import SwiftUI

struct PauseOverlay: View {
    let onResume: () -> Void
    let onRestart: () -> Void
    let onHome: () -> Void

    var body: some View {
        OverlayPanel(title: "Paused") {
            TicketButton(title: "Resume", compact: true, action: onResume)
            TicketButton(title: "Restart", compact: true, action: onRestart)
            TicketButton(title: "Home", compact: true, action: onHome)
        }
    }
}
