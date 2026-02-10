import XCTest
@testable import FeatureDailyPuzzle

final class DailyPuzzleStringsTests: XCTestCase {
    func testChallengeProgressIncludesCounts() {
        let value = DailyPuzzleStrings.challengeProgress(found: 2, total: 5)
        XCTAssertTrue(value.contains("2"))
        XCTAssertTrue(value.contains("5"))
    }

    func testChallengeAccessibilityContainsChallengeNumber() {
        let value = DailyPuzzleStrings.challengeAccessibilityLabel(number: 7, status: "Completed")
        XCTAssertTrue(value.contains("7"))
    }
}
