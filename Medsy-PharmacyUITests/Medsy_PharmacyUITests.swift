//
//  Medsy_PharmacyUITests.swift
//  Medsy-PharmacyUITests
//
//  Created by Ahmed Elkady on 16/07/2026.
//

import XCTest

final class Medsy_PharmacyUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
