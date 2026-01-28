import SwiftUI
import Combine

@MainActor
final class MindGameInputEngine: ObservableObject {

    struct Move {
        let fromIndex: Int
        let toIndex: Int
    }

    struct Output {
        let didMove: Bool
        let didCombine: Bool
        let scoreDelta: Int
    }

    @Published private(set) var lastMove: Move? = nil
    @Published private(set) var lastOutput: Output? = nil

    init() {}

    func applyMove(from: Int, to: Int) -> Output {
        let move = Move(fromIndex: from, toIndex: to)
        lastMove = move

        let didCombine = from == to
        let score = didCombine ? (from + to) : 0

        let output = Output(
            didMove: true,
            didCombine: didCombine,
            scoreDelta: score
        )

        lastOutput = output
        return output
    }

    func reset() {
        lastMove = nil
        lastOutput = nil
    }
}
