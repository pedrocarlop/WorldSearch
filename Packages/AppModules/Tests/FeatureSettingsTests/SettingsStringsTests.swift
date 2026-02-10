import XCTest
import Core
@testable import FeatureSettings

final class SettingsStringsTests: XCTestCase {
    func testAppearanceTitlesAreNotEmpty() {
        XCTAssertFalse(SettingsStrings.appearanceTitle(for: .system).isEmpty)
        XCTAssertFalse(SettingsStrings.appearanceTitle(for: .light).isEmpty)
        XCTAssertFalse(SettingsStrings.appearanceTitle(for: .dark).isEmpty)
    }

    func testCelebrationTitlesAreNotEmpty() {
        XCTAssertFalse(SettingsStrings.celebrationTitle(for: .low).isEmpty)
        XCTAssertFalse(SettingsStrings.celebrationTitle(for: .medium).isEmpty)
        XCTAssertFalse(SettingsStrings.celebrationTitle(for: .high).isEmpty)
    }

    func testLanguageTitlesAreNotEmpty() {
        XCTAssertFalse(SettingsStrings.languageTitle(for: .english).isEmpty)
        XCTAssertFalse(SettingsStrings.languageTitle(for: .spanish).isEmpty)
        XCTAssertFalse(SettingsStrings.languageTitle(for: .french).isEmpty)
        XCTAssertFalse(SettingsStrings.languageTitle(for: .portuguese).isEmpty)
    }

    func testLanguageManagedInfoStringsAreNotEmpty() {
        XCTAssertFalse(SettingsStrings.languageDeviceManagedTitle.isEmpty)
        XCTAssertFalse(SettingsStrings.languageDeviceManagedMessage.isEmpty)
        XCTAssertFalse(SettingsStrings.languageOpenSettings.isEmpty)
    }
}
