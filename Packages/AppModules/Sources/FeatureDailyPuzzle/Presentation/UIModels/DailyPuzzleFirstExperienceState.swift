import Foundation

public enum DailyPuzzleFirstExperienceStep: Int, CaseIterable, Equatable, Sendable {
    case dragToSelect
    case objectivesHint
    case difficultyHint

    var next: DailyPuzzleFirstExperienceStep? {
        switch self {
        case .dragToSelect:
            return .objectivesHint
        case .objectivesHint:
            return .difficultyHint
        case .difficultyHint:
            return nil
        }
    }
}

public struct DailyPuzzleFirstExperienceState: Equatable, Sendable {
    public private(set) var step: DailyPuzzleFirstExperienceStep?

    public init(enabled: Bool) {
        step = enabled ? .dragToSelect : nil
    }

    public var isActive: Bool {
        step != nil
    }

    public var isObjectivesHighlightVisible: Bool {
        step == .objectivesHint
    }

    @discardableResult
    public mutating func advance() -> Bool {
        guard let step else { return false }
        if let nextStep = step.next {
            self.step = nextStep
            return false
        }

        self.step = nil
        return true
    }

    @discardableResult
    public mutating func skipAll() -> Bool {
        guard isActive else { return false }
        step = nil
        return true
    }
}
