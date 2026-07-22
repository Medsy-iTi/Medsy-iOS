//
//  PharmacyCallHandlerTests.swift
//  MedsyTests
//
//  Created by Antoneos Philip on 21/07/2026.
//

import XCTest
@testable import Medsy

final class PharmacyCallHandlerTests: XCTestCase {
    func testCleanPhoneNumberRemovesNonDigits() {
        let rawNumber = "+20 (101) 234-5678"
        let cleaned = PharmacyCallHandler.cleanPhoneNumber(rawNumber)
        XCTAssertEqual(cleaned, "201012345678")
    }

    func testMakeCallURLReturnsValidPromptURL() {
        let rawNumber = "01012345678"
        let url = PharmacyCallHandler.makeCallURL(for: rawNumber)
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("01012345678") == true)
    }

    func testMakeCallURLReturnsNilForEmptyNumber() {
        let rawNumber = "---"
        let url = PharmacyCallHandler.makeCallURL(for: rawNumber)
        XCTAssertNil(url)
    }
}
