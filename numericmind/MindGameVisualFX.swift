import SwiftUI
import Combine

enum MindGameVisualFX {

    static func popScale(_ t: Double) -> Double {
        let x = max(0, min(1, t))
        let a = 1.0 + 0.10 * sin(x * .pi)
        return a
    }

    static func easeOut(_ x: Double) -> Double {
        let t = max(0, min(1, x))
        return 1 - pow(1 - t, 3)
    }

    static func easeInOut(_ x: Double) -> Double {
        let t = max(0, min(1, x))
        return t * t * (3 - 2 * t)
    }
}

@MainActor
final class MindGameFXEmitter: ObservableObject {

    struct Spark: Identifiable, Equatable {
        let id: UUID
        var seed: UInt64
        var bornAt: TimeInterval
        var life: Double
        var origin: CGPoint
        var drift: CGPoint
        var size: CGFloat
        var angle: Double
        var spin: Double
        var tint: Color

        init(
            origin: CGPoint,
            drift: CGPoint,
            size: CGFloat,
            life: Double,
            tint: Color,
            seed: UInt64 = UInt64.random(in: 1...UInt64.max),
            bornAt: TimeInterval = Date().timeIntervalSince1970
        ) {
            self.id = UUID()
            self.seed = seed
            self.bornAt = bornAt
            self.life = life
            self.origin = origin
            self.drift = drift
            self.size = size
            self.angle = Double.random(in: 0...360)
            self.spin = Double.random(in: -140...140)
            self.tint = tint
        }

        func progress(now: TimeInterval) -> Double {
            let t = (now - bornAt) / max(0.001, life)
            return max(0, min(1, t))
        }

        func isAlive(now: TimeInterval) -> Bool {
            progress(now: now) < 1
        }
    }

    @Published private(set) var sparks: [Spark] = []

    private var timer: AnyCancellable?

    deinit {
        timer?.cancel()
        timer = nil
    }

    func burst(
        at origin: CGPoint,
        count: Int = 16,
        spread: CGFloat = 120,
        life: Double = 0.8
    ) {
        let n = max(1, min(48, count))
        let now = Date().timeIntervalSince1970

        for i in 0..<n {
            let a = Double(i) / Double(n) * (.pi * 2)
            let r = CGFloat.random(in: spread * 0.25...spread)
            let dx = cos(a) * r
            let dy = sin(a) * r

            let drift = CGPoint(x: dx, y: dy)
            let size = CGFloat.random(in: 5...10)
            let tint = paletteColor(Int.random(in: 0...6))

            sparks.append(
                Spark(
                    origin: origin,
                    drift: drift,
                    size: size,
                    life: life * Double.random(in: 0.85...1.15),
                    tint: tint,
                    bornAt: now
                )
            )
        }

        ensureTicker()
    }

    func clear() {
        sparks.removeAll()
        timer?.cancel()
        timer = nil
    }

    private func ensureTicker() {
        guard timer == nil else { return }
        timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.tick()
            }
    }

    private func tick() {
        let now = Date().timeIntervalSince1970
        sparks.removeAll { !$0.isAlive(now: now) }
        if sparks.isEmpty {
            timer?.cancel()
            timer = nil
        }
    }

    private func paletteColor(_ i: Int) -> Color {
        switch i % 7 {
        case 0: return Color(red: 0.30, green: 0.80, blue: 0.98)
        case 1: return Color(red: 0.95, green: 0.45, blue: 0.70)
        case 2: return Color(red: 0.72, green: 0.56, blue: 0.98)
        case 3: return Color(red: 0.40, green: 0.92, blue: 0.70)
        case 4: return Color(red: 0.98, green: 0.86, blue: 0.42)
        case 5: return Color(red: 0.92, green: 0.62, blue: 0.26)
        default: return Color.white.opacity(0.9)
        }
    }
}

struct MindGameFXLayer: View {

    @ObservedObject var emitter: MindGameFXEmitter

    var body: some View {
        GeometryReader { geo in
            let now = Date().timeIntervalSince1970

            ZStack {
                ForEach(emitter.sparks) { s in
                    let p = s.progress(now: now)
                    let e = MindGameVisualFX.easeOut(p)
                    let x = s.origin.x + s.drift.x * CGFloat(e)
                    let y = s.origin.y + s.drift.y * CGFloat(e)
                    let a = 1.0 - p
                    let sc = 0.85 + 0.35 * MindGameVisualFX.popScale(1 - p)

                    RoundedRectangle(cornerRadius: s.size * 0.4, style: .continuous)
                        .fill(s.tint.opacity(0.95))
                        .frame(width: s.size, height: s.size)
                        .scaleEffect(sc)
                        .rotationEffect(.degrees(s.angle + s.spin * p))
                        .position(x: x, y: y)
                        .opacity(a)
                        .blur(radius: CGFloat(1.5 * p))
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .allowsHitTesting(false)
        }
    }
}
