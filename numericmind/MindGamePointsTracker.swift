import SwiftUI
import Combine

@MainActor
final class MindGamePointsTracker: ObservableObject {

    @Published private(set) var score: Int = 0
    @Published private(set) var bestScore: Int = 0

    private let bestKey = "mindgame.bestScore"

    init() {
        bestScore = UserDefaults.standard.integer(forKey: bestKey)
    }

    func add(_ value: Int) {
        guard value != 0 else { return }
        let next = score + value
        score = max(0, next)
        if score > bestScore {
            bestScore = score
            UserDefaults.standard.set(bestScore, forKey: bestKey)
        }
    }

    func set(_ value: Int) {
        score = max(0, value)
        if score > bestScore {
            bestScore = score
            UserDefaults.standard.set(bestScore, forKey: bestKey)
        }
    }

    func resetRun() {
        score = 0
    }

    func resetAll() {
        score = 0
        bestScore = 0
        UserDefaults.standard.removeObject(forKey: bestKey)
    }
}
