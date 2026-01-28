import SwiftUI
import Combine

struct MindGameLoadingScreen: View {

    @State private var t: Double = 0
    @State private var pulse: Bool = false
    @State private var drift: CGFloat = 0

    var body: some View {
        ZStack {
            MindGameTheme.background
                .ignoresSafeArea()

            ColorfulBubbles(t: t, drift: drift)
                .blendMode(.screen)
                .opacity(0.9)

            FallingDigits(t: t)
                .opacity(0.85)

            VStack(spacing: 14) {
                Spacer()

                Tile2048Spinner(t: t, pulse: pulse)
                    .frame(width: 220, height: 220)   // ⬅️ было 180

                Text("Loading")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(MindGameTheme.textPrimary.opacity(0.9))
                    .scaleEffect(pulse ? 1.02 : 0.98)

                Spacer()
            }
            .padding(.bottom, 12)
        }
        .onAppear {
            withAnimation(.linear(duration: 14).repeatForever(autoreverses: false)) {
                t = 1
            }
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulse = true
            }
            withAnimation(.easeInOut(duration: 3.4).repeatForever(autoreverses: true)) {
                drift = 1
            }
        }
    }
}

// MARK: - Background bubbles

private struct ColorfulBubbles: View {

    let t: Double
    let drift: CGFloat

    var body: some View {
        GeometryReader { g in
            let w = g.size.width
            let h = g.size.height
            let phase = t * .pi * 2

            ZStack {
                bubble(
                    size: 320,
                    x: w * 0.18,
                    y: h * 0.22,
                    color: .blue,
                    dx: sin(phase) * 42,
                    dy: cos(phase) * 32
                )

                bubble(
                    size: 260,
                    x: w * 0.85,
                    y: h * 0.38,
                    color: .purple,
                    dx: cos(phase * 0.8) * 36,
                    dy: sin(phase * 0.9) * 30
                )

                bubble(
                    size: 300,
                    x: w * 0.48,
                    y: h * 0.82,
                    color: .orange,
                    dx: sin(phase * 1.1) * 34,
                    dy: cos(phase * 0.7) * 28
                )
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func bubble(
        size: CGFloat,
        x: CGFloat,
        y: CGFloat,
        color: Color,
        dx: CGFloat,
        dy: CGFloat
    ) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        color.opacity(0.45),
                        color.opacity(0.18),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 12,
                    endRadius: size * 0.6
                )
            )
            .frame(width: size, height: size)
            .position(x: x + dx, y: y + dy)
            .blur(radius: 26)
    }
}

// MARK: - Falling digits

private struct FallingDigits: View {

    let t: Double
    private let digits = ["2", "4", "8", "16", "32", "64"]

    var body: some View {
        GeometryReader { _ in
            Canvas { ctx, size in
                let phase = t * .pi * 2

                for i in 0..<30 {
                    let k = Double(i) / 30.0
                    let y = CGFloat((phase + k * 3.5).truncatingRemainder(dividingBy: 1)) * size.height
                    let x = CGFloat(k) * size.width + CGFloat(sin(phase + k * 6)) * 24

                    let value = digits[i % digits.count]
                    let alpha = 0.18 + 0.35 * (1 - k)

                    let text = Text(value)
                        .font(.system(size: 16 + CGFloat((1 - k) * 22), weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(alpha))

                    ctx.draw(text, at: CGPoint(x: x, y: y))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Central spinner

private struct Tile2048Spinner: View {

    let t: Double
    let pulse: Bool

    var body: some View {
        GeometryReader { g in
            let side = min(g.size.width, g.size.height)
            let phase = t * .pi * 2

            ZStack {
                ForEach(0..<8, id: \.self) { i in
                    let angle = Double(i) / 8.0 * .pi * 2 + phase
                    let r = side * 0.40          // ⬅️ было 0.36
                    let x = cos(angle) * r
                    let y = sin(angle) * r

                    TileView(value: tileValue(i))
                        .frame(
                            width: side * 0.26,  // ⬅️ было 0.22
                            height: side * 0.26
                        )
                        .offset(x: x, y: y)
                        .rotationEffect(.degrees(angle * 180 / .pi))
                }

                TileView(value: "2048")
                    .frame(
                        width: side * 0.44,      // ⬅️ было 0.36
                        height: side * 0.44
                    )
                    .scaleEffect(pulse ? 1.05 : 0.97)
            }
        }
        .allowsHitTesting(false)
    }

    private func tileValue(_ i: Int) -> String {
        ["2", "4", "8", "16", "32", "64", "128", "256"][i % 8]
    }
}

// MARK: - Tile

private struct TileView: View {

    let value: String

    var body: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(tileColor)
            .overlay(
                Text(value)
                    .font(
                        .system(
                            size: value == "2048" ? 30 : 24,   // ⬅️ увеличены шрифты
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundColor(.white)
            )
            .shadow(color: tileColor.opacity(0.45), radius: 14)
    }

    private var tileColor: Color {
        switch value {
        case "2": return .blue
        case "4": return .green
        case "8": return .orange
        case "16": return .pink
        case "32": return .purple
        case "64": return .red
        case "128": return .mint
        case "256": return .cyan
        case "2048": return .yellow
        default: return .gray
        }
    }
}
