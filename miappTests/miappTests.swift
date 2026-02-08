//
//  miappTests.swift
//  miappTests
//
//  Created by Pedro Carrasco lopez brea on 8/2/26.
//

import CoreGraphics
import XCTest
@testable import miapp

final class miappTests: XCTestCase {
    func testLoupeStateVisibility() {
        var state = LoupeState(configuration: .default)
        let bounds = CGRect(x: 0, y: 0, width: 200, height: 200)

        XCTAssertFalse(state.isVisible)
        state.update(
            fingerLocation: CGPoint(x: 40, y: 60),
            in: bounds,
            configuration: .default
        )
        XCTAssertTrue(state.isVisible)

        state.hide()
        XCTAssertFalse(state.isVisible)
    }

    func testLoupeStateClampsPosition() {
        var config = LoupeConfiguration.default
        config.size = CGSize(width: 100, height: 100)
        config.offset = CGSize(width: 0, height: -70)
        config.edgePadding = 8

        var state = LoupeState(configuration: config)
        let bounds = CGRect(x: 0, y: 0, width: 200, height: 200)

        state.update(
            fingerLocation: CGPoint(x: 5, y: 5),
            in: bounds,
            configuration: config
        )

        let insetX = config.size.width * 0.5 + config.edgePadding
        let insetY = config.size.height * 0.5 + config.edgePadding
        XCTAssertGreaterThanOrEqual(state.loupeScreenPosition.x, insetX - 0.001)
        XCTAssertGreaterThanOrEqual(state.loupeScreenPosition.y, insetY - 0.001)
    }

    func testLoupeStateSmoothingLerpsTowardTarget() {
        var config = LoupeConfiguration.default
        config.smoothing = 0.2

        var state = LoupeState(configuration: config)
        let bounds = CGRect(x: 0, y: 0, width: 240, height: 240)

        state.update(
            fingerLocation: CGPoint(x: 60, y: 60),
            in: bounds,
            configuration: config
        )

        let initial = state.loupeScreenPosition

        state.update(
            fingerLocation: CGPoint(x: 180, y: 180),
            in: bounds,
            configuration: config
        )

        let updated = state.loupeScreenPosition
        XCTAssertNotEqual(initial, updated)
        XCTAssertLessThan(updated.x, 180 + config.offset.width)
        XCTAssertLessThan(updated.y, 180 + config.offset.height)
    }
}
