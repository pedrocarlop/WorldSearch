import XCTest
@testable import FeatureHistory

final class HistoryStringsTests: XCTestCase {
    func testHistoryTitlesAreNotEmpty() {
        XCTAssertFalse(HistoryStrings.completedPuzzlesTitle.isEmpty)
        XCTAssertFalse(HistoryStrings.streakTitle.isEmpty)
    }

    func testHistoryExplanationsAreNotEmpty() {
        XCTAssertFalse(HistoryStrings.completedPuzzlesExplanation.isEmpty)
        XCTAssertFalse(HistoryStrings.streakExplanation.isEmpty)
    }
}
