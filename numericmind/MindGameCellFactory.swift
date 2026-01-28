import SwiftUI
import Combine

@MainActor
final class MindGameCellFactory: ObservableObject {

    struct Spec: Equatable {
        var value: Int
        var isHighlighted: Bool
        var isMerged: Bool

        init(value: Int, isHighlighted: Bool = false, isMerged: Bool = false) {
            self.value = value
            self.isHighlighted = isHighlighted
            self.isMerged = isMerged
        }
    }

    @Published private(set) var lastStamp: UUID = UUID()

    init() {}

    func make(
        value: Int,
        isHighlighted: Bool = false,
        isMerged: Bool = false
    ) -> Spec {
        Spec(value: value, isHighlighted: isHighlighted, isMerged: isMerged)
    }

    func bump() {
        lastStamp = UUID()
    }

    func view(for spec: Spec) -> some View {
        MindGameCellNode(
            value: spec.value,
            isHighlighted: spec.isHighlighted,
            isMerged: spec.isMerged
        )
        .id("\(spec.value)-\(spec.isHighlighted)-\(spec.isMerged)-\(lastStamp.uuidString)")
    }
}
