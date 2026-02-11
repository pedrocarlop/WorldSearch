import XCTest
@testable import FeatureDailyPuzzle

final class DailyPuzzleFirstExperienceStateTests: XCTestCase {
    func testEnabledStateStartsAtStepOne() {
        let state = DailyPuzzleFirstExperienceState(enabled: true)

        XCTAssertTrue(state.isActive)
        XCTAssertEqual(state.step, .dragToSelect)
    }

    func testAdvanceTransitionsToCompletion() {
        var state = DailyPuzzleFirstExperienceState(enabled: true)

        XCTAssertFalse(state.advance())
        XCTAssertEqual(state.step, .objectivesHint)
        XCTAssertTrue(state.isObjectivesHighlightVisible)

        XCTAssertFalse(state.advance())
        XCTAssertEqual(state.step, .difficultyHint)
        XCTAssertFalse(state.isObjectivesHighlightVisible)

        XCTAssertTrue(state.advance())
        XCTAssertNil(state.step)
        XCTAssertFalse(state.isActive)
    }

    func testSkipAllCompletesImmediately() {
        var state = DailyPuzzleFirstExperienceState(enabled: true)

        XCTAssertTrue(state.skipAll())
        XCTAssertNil(state.step)
        XCTAssertFalse(state.isActive)
    }

    func testDisabledStateStaysInactive() {
        var state = DailyPuzzleFirstExperienceState(enabled: false)

        XCTAssertFalse(state.isActive)
        XCTAssertNil(state.step)
        XCTAssertFalse(state.advance())
        XCTAssertFalse(state.skipAll())
    }
}
