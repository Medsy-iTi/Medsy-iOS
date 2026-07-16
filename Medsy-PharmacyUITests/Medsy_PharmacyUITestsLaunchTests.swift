//
//  Medsy_PharmacyUITestsLaunchTests.swift
//  Medsy-PharmacyUITests
//
//  Created by Ahmed Elkady on 16/07/2026.
//

import XCTest

final class Medsy_PharmacyUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
