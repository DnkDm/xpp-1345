import UIKit

extension UIColor {
    convenience init(hex: String) {
        let value = Int(
            hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted),
            radix: 16
        ) ?? 0
        self.init(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }

    /// Straight RGB mix, used to fade the Sky Hop sky from day to night.
    func blended(with other: UIColor, amount: CGFloat) -> UIColor {
        let fraction = min(max(amount, 0), 1)
        var (red, green, blue, alpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        var (otherRed, otherGreen, otherBlue, otherAlpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        other.getRed(&otherRed, green: &otherGreen, blue: &otherBlue, alpha: &otherAlpha)
        return UIColor(
            red: red + (otherRed - red) * fraction,
            green: green + (otherGreen - green) * fraction,
            blue: blue + (otherBlue - blue) * fraction,
            alpha: alpha + (otherAlpha - alpha) * fraction
        )
    }
}
