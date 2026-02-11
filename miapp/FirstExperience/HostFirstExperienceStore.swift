import Foundation
import Core

final class HostFirstExperienceStore {
    static let uiTestResetArgument = "--uitesting-reset-first-experience"

    private enum Keys {
        static let puzzleFirstExperienceCompleted = "puzzle_first_experience_completed_v1"
    }

    static let live = HostFirstExperienceStore(defaults: HostFirstExperienceStore.makeLiveDefaults())

    private let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    var shouldShowPuzzleFirstExperience: Bool {
        let completed = defaults.object(forKey: Keys.puzzleFirstExperienceCompleted) as? Bool ?? false
        return !completed
    }

    func markPuzzleFirstExperienceCompleted() {
        defaults.set(true, forKey: Keys.puzzleFirstExperienceCompleted)
    }

    func resetForUITestingIfNeeded(launchArguments: [String]) {
        guard launchArguments.contains(Self.uiTestResetArgument) else { return }
        defaults.removeObject(forKey: Keys.puzzleFirstExperienceCompleted)
    }

    static func resetForUITestingIfNeeded(launchArguments: [String]) {
        let store = HostFirstExperienceStore(defaults: makeLiveDefaults())
        store.resetForUITestingIfNeeded(launchArguments: launchArguments)
    }

    private static func makeLiveDefaults() -> UserDefaults {
        UserDefaults(suiteName: WordSearchConfig.suiteName) ?? .standard
    }
}
