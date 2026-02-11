import XCTest
import Foundation
@testable import miapp

@MainActor
final class HostFirstExperienceStoreTests: XCTestCase {
    private func makeDefaults() -> UserDefaults {
        let suiteName = "HostFirstExperienceStoreTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    func testShouldShowDefaultsToTrueWhenNotPersisted() {
        let store = HostFirstExperienceStore(defaults: makeDefaults())

        XCTAssertTrue(store.shouldShowPuzzleFirstExperience)
    }

    func testMarkCompletedHidesFirstExperience() {
        let store = HostFirstExperienceStore(defaults: makeDefaults())

        store.markPuzzleFirstExperienceCompleted()

        XCTAssertFalse(store.shouldShowPuzzleFirstExperience)
    }

    func testResetForUITestingClearsFlag() {
        let store = HostFirstExperienceStore(defaults: makeDefaults())
        store.markPuzzleFirstExperienceCompleted()

        store.resetForUITestingIfNeeded(launchArguments: [HostFirstExperienceStore.uiTestResetArgument])

        XCTAssertTrue(store.shouldShowPuzzleFirstExperience)
    }
}
