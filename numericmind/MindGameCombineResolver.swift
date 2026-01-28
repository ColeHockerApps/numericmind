import SwiftUI
import Combine

@MainActor
final class MindGameCombineResolver: ObservableObject {

    struct Input: Equatable {
        let from: Int
        let to: Int
    }

    struct Result: Equatable {
        let value: Int
        let didCombine: Bool
    }

    init() {}

    func resolve(_ input: Input) -> Result {
        if input.from == input.to {
            return Result(value: input.from + input.to, didCombine: true)
        } else {
            return Result(value: input.to, didCombine: false)
        }
    }

    func canCombine(_ a: Int, _ b: Int) -> Bool {
        a == b
    }
}
