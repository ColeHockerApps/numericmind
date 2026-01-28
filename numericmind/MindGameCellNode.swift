import SwiftUI
import Combine

struct MindGameCellNode: View {

    let value: Int
    let isHighlighted: Bool
    let isMerged: Bool

    @State private var appear: Bool = false
    @State private var pulse: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(borderColor, lineWidth: isHighlighted ? 2 : 0)
                )

            if value > 0 {
                Text("\(value)")
                    .font(.system(size: fontSize, weight: .bold, design: .rounded))
                    .foregroundColor(textColor)
                    .scaleEffect(pulse ? 1.08 : 1.0)
            }
        }
        .scaleEffect(appear ? 1.0 : 0.6)
        .opacity(appear ? 1.0 : 0.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: appear)
        .animation(.easeInOut(duration: 0.25), value: pulse)
        .onAppear {
            appear = true
            if isMerged {
                pulse = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                    pulse = false
                }
            }
        }
    }

    private var backgroundColor: Color {
        if value == 0 {
            return Color.white.opacity(0.08)
        }

        switch value {
        case 2:   return Color(red: 0.45, green: 0.72, blue: 0.95)
        case 4:   return Color(red: 0.55, green: 0.85, blue: 0.72)
        case 8:   return Color(red: 0.98, green: 0.75, blue: 0.40)
        case 16:  return Color(red: 0.98, green: 0.55, blue: 0.45)
        case 32:  return Color(red: 0.92, green: 0.45, blue: 0.72)
        case 64:  return Color(red: 0.72, green: 0.54, blue: 0.98)
        default:  return Color(red: 0.85, green: 0.85, blue: 0.95)
        }
    }

    private var textColor: Color {
        value <= 4 ? Color.black.opacity(0.75) : Color.white
    }

    private var borderColor: Color {
        isHighlighted ? Color.white.opacity(0.85) : Color.clear
    }

    private var fontSize: CGFloat {
        switch value {
        case 0: return 0
        case 2, 4: return 34
        case 8, 16: return 32
        case 32, 64: return 28
        default: return 24
        }
    }
}
