import SwiftUI
import Combine

@MainActor
final class MindGameBoardEngine: ObservableObject {

    struct Cell: Identifiable, Equatable {
        let id: UUID
        var value: Int
        var isLocked: Bool

        init(value: Int, isLocked: Bool = false) {
            self.id = UUID()
            self.value = value
            self.isLocked = isLocked
        }
    }

    @Published private(set) var size: Int = 4
    @Published private(set) var cells: [Cell] = []
    @Published private(set) var score: Int = 0
    @Published private(set) var moves: Int = 0
    @Published private(set) var didChangeLastStep: Bool = false

    @Published private(set) var lastSpawnedIDs: [UUID] = []
    @Published private(set) var lastMergedIDs: [UUID] = []
    @Published private(set) var lastMoveDirection: Direction? = nil

    enum Direction: Int, CaseIterable {
        case left
        case right
        case up
        case down
    }

    private var rng = SystemRandomNumberGenerator()

    init(size: Int = 4) {
        configure(size: size)
    }

    func configure(size: Int) {
        let s = max(2, min(8, size))
        self.size = s
        reset()
    }

    func reset() {
        score = 0
        moves = 0
        didChangeLastStep = false
        lastSpawnedIDs = []
        lastMergedIDs = []
        lastMoveDirection = nil

        cells = Array(repeating: Cell(value: 0), count: size * size)
        spawn(count: 2)
    }

    func step(_ direction: Direction) {
        lastMoveDirection = direction
        lastSpawnedIDs = []
        lastMergedIDs = []

        let before = cells
        let result = apply(direction, on: cells)

        cells = result.cells
        score += result.scoreGained
        didChangeLastStep = (before != cells)

        if didChangeLastStep {
            moves += 1
            spawn(count: 1)
        }
    }

    func canMove() -> Bool {
        if cells.contains(where: { $0.value == 0 }) { return true }
        for r in 0..<size {
            for c in 0..<size {
                let v = valueAt(r, c)
                if c + 1 < size, v == valueAt(r, c + 1) { return true }
                if r + 1 < size, v == valueAt(r + 1, c) { return true }
            }
        }
        return false
    }

    func maxValue() -> Int {
        cells.map(\.value).max() ?? 0
    }

    private func valueAt(_ r: Int, _ c: Int) -> Int {
        cells[r * size + c].value
    }

    private func setValueAt(_ r: Int, _ c: Int, _ v: Int) {
        cells[r * size + c].value = v
    }

    private func spawn(count: Int) {
        var spawned: [UUID] = []
        for _ in 0..<count {
            let empties = cells.indices.filter { cells[$0].value == 0 && cells[$0].isLocked == false }
            if empties.isEmpty { break }
            let idx = empties.randomElement(using: &rng) ?? empties[0]
            let v = rollSpawnValue()
            cells[idx].value = v
            spawned.append(cells[idx].id)
        }
        lastSpawnedIDs = spawned
    }

    private func rollSpawnValue() -> Int {
        let p = Int.random(in: 0..<100, using: &rng)
        return p < 85 ? 2 : 4
    }

    private struct ApplyResult {
        var cells: [Cell]
        var scoreGained: Int
        var mergedIDs: [UUID]
    }

    private func apply(_ direction: Direction, on input: [Cell]) -> ApplyResult {
        var work = input
        var gained = 0
        var merged: [UUID] = []

        func extractLine(_ index: Int) -> [Cell] {
            var out: [Cell] = []
            out.reserveCapacity(size)
            switch direction {
            case .left:
                for c in 0..<size { out.append(work[index * size + c]) }
            case .right:
                for c in (0..<size).reversed() { out.append(work[index * size + c]) }
            case .up:
                for r in 0..<size { out.append(work[r * size + index]) }
            case .down:
                for r in (0..<size).reversed() { out.append(work[r * size + index]) }
            }
            return out
        }

        func writeLine(_ index: Int, _ line: [Cell]) {
            switch direction {
            case .left:
                for c in 0..<size { work[index * size + c] = line[c] }
            case .right:
                for c in 0..<size { work[index * size + (size - 1 - c)] = line[c] }
            case .up:
                for r in 0..<size { work[r * size + index] = line[r] }
            case .down:
                for r in 0..<size { work[(size - 1 - r) * size + index] = line[r] }
            }
        }

        for i in 0..<size {
            let line = extractLine(i)
            let r = compressMerge(line)
            gained += r.scoreGained
            merged.append(contentsOf: r.mergedIDs)
            writeLine(i, r.line)
        }

        return ApplyResult(cells: work, scoreGained: gained, mergedIDs: merged)
    }

    private struct LineResult {
        var line: [Cell]
        var scoreGained: Int
        var mergedIDs: [UUID]
    }

    private func compressMerge(_ line: [Cell]) -> LineResult {
        var gained = 0
        var merged: [UUID] = []

        var values = line.filter { $0.value != 0 && $0.isLocked == false }
        var locked = line.filter { $0.isLocked == true }

        var outValues: [Int] = []
        outValues.reserveCapacity(size)

        var i = 0
        while i < values.count {
            let a = values[i].value
            if i + 1 < values.count, values[i + 1].value == a {
                let newV = a * 2
                gained += newV
                outValues.append(newV)
                merged.append(values[i].id)
                merged.append(values[i + 1].id)
                i += 2
            } else {
                outValues.append(a)
                i += 1
            }
        }

        var out: [Cell] = []
        out.reserveCapacity(size)

        for v in outValues {
            out.append(Cell(value: v))
        }

        while out.count < size - locked.count {
            out.append(Cell(value: 0))
        }

        if locked.isEmpty == false {
            for l in locked {
                out.append(Cell(value: l.value, isLocked: true))
            }
            if out.count > size { out = Array(out.prefix(size)) }
        }

        while out.count < size { out.append(Cell(value: 0)) }

        return LineResult(line: out, scoreGained: gained, mergedIDs: merged)
    }
}
