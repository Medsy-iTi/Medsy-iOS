//
//  PharmacyAppSettingsTests.swift
//  Medsy-PharmacyTests
//
//  Created by Ehab Salah on 14/08/2026.
//

import SwiftUI
import XCTest
@testable import Medsy_Pharmacy

final class PharmacyAppSettingsTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "PharmacyAppSettingsTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testFreshInstallDefaultsToSystemTheme() {
        let settings = PharmacyAppSettings(
            defaults: defaults,
            initialColorScheme: .dark
        )

        XCTAssertEqual(settings.themePreference, .system)
        XCTAssertNil(settings.preferredColorScheme)
        XCTAssertTrue(settings.isDarkMode)
        XCTAssertEqual(defaults.string(forKey: "pharmacy_theme_preference"), "system")
    }

    func testSystemThemeTracksColorSchemeChanges() {
        let settings = PharmacyAppSettings(
            defaults: defaults,
            initialColorScheme: .light
        )

        XCTAssertFalse(settings.isDarkMode)

        settings.updateSystemColorScheme(.dark)

        XCTAssertTrue(settings.isDarkMode)
    }

    func testExplicitThemePreferencePersists() {
        let settings = PharmacyAppSettings(
            defaults: defaults,
            initialColorScheme: .light
        )
        settings.themePreference = .dark

        let restoredSettings = PharmacyAppSettings(
            defaults: defaults,
            initialColorScheme: .light
        )

        XCTAssertEqual(restoredSettings.themePreference, .dark)
        XCTAssertEqual(restoredSettings.preferredColorScheme, .dark)
        XCTAssertTrue(restoredSettings.isDarkMode)
    }

    func testLegacyDarkModePreferenceIsMigrated() {
        defaults.set(true, forKey: "pharmacy_is_dark_mode")

        let settings = PharmacyAppSettings(
            defaults: defaults,
            initialColorScheme: .light
        )

        XCTAssertEqual(settings.themePreference, .dark)
        XCTAssertEqual(defaults.string(forKey: "pharmacy_theme_preference"), "dark")
    }
}
