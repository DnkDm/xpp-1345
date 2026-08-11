import SwiftUI

extension Color {
    init(hex: String) {
        let value = Int(
            hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted),
            radix: 16
        ) ?? 0
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}
