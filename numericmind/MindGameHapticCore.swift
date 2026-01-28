import SwiftUI
import Combine
import UIKit

@MainActor
final class MindGameHapticsCore: ObservableObject {

    static let shared = MindGameHapticsCore()

    private var isEnabled: Bool = true
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selection = UISelectionFeedbackGenerator()
    private let notify = UINotificationFeedbackGenerator()

    private init() {}

    func setEnabled(_ value: Bool) {
        isEnabled = value
    }

    func prepare() {
        guard isEnabled else { return }
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        selection.prepare()
        notify.prepare()
    }

    func tapSoft() {
        guard isEnabled else { return }
        impactLight.impactOccurred(intensity: 0.8)
    }

    func tapFirm() {
        guard isEnabled else { return }
        impactMedium.impactOccurred(intensity: 0.95)
    }

    func tapHeavy() {
        guard isEnabled else { return }
        impactHeavy.impactOccurred(intensity: 1.0)
    }

    func select() {
        guard isEnabled else { return }
        selection.selectionChanged()
    }

    func success() {
        guard isEnabled else { return }
        notify.notificationOccurred(.success)
    }

    func warning() {
        guard isEnabled else { return }
        notify.notificationOccurred(.warning)
    }

    func error() {
        guard isEnabled else { return }
        notify.notificationOccurred(.error)
    }
}
