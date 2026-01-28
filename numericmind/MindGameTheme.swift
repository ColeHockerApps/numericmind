import SwiftUI
import Combine

enum MindGameTheme {

    static let background = LinearGradient(
        colors: [
            Color(red: 0.03, green: 0.04, blue: 0.08),
            Color(red: 0.06, green: 0.07, blue: 0.14),
            Color(red: 0.03, green: 0.05, blue: 0.10)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let surface = Color(red: 0.12, green: 0.14, blue: 0.22)

    static let neonBlue   = Color(red: 0.46, green: 0.78, blue: 0.98)
    static let neonViolet = Color(red: 0.62, green: 0.42, blue: 0.98)
    static let neonPink   = Color(red: 0.98, green: 0.55, blue: 0.68)
    static let neonGreen  = Color(red: 0.42, green: 0.92, blue: 0.72)
    static let neonGold   = Color(red: 0.98, green: 0.82, blue: 0.40)

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.72)
    static let textMuted = Color.white.opacity(0.45)

    static let glowSoft = Color.white.opacity(0.18)
    static let glowStrong = Color.white.opacity(0.35)

    static func neonGradient(_ a: Color, _ b: Color) -> LinearGradient {
        LinearGradient(
            colors: [a, b],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func glowCircle(color: Color, radius: CGFloat = 18) -> some View {
        Circle()
            .fill(color)
            .blur(radius: radius)
            .opacity(0.65)
    }
}
