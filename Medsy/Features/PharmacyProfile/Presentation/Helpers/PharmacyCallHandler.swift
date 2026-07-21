//
//  PharmacyCallHandler.swift
//  Medsy
//
//  Created by Antoneos Philip on 21/07/2026.
//

import UIKit

enum PharmacyCallHandler {
    static func cleanPhoneNumber(_ rawNumber: String) -> String {
        rawNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }

    static func makeCallURL(for rawNumber: String) -> URL? {
        let cleaned = cleanPhoneNumber(rawNumber)
        guard !cleaned.isEmpty else { return nil }
        return URL(string: "telprompt://\(cleaned)") ?? URL(string: "tel://\(cleaned)")
    }

    @MainActor
    static func call(phoneNumber: String) {
        let cleaned = cleanPhoneNumber(phoneNumber)
        guard !cleaned.isEmpty else { return }

        let promptScheme = "telprompt://\(cleaned)"
        let telScheme = "tel://\(cleaned)"

        if let promptURL = URL(string: promptScheme), UIApplication.shared.canOpenURL(promptURL) {
            UIApplication.shared.open(promptURL)
        } else if let telURL = URL(string: telScheme), UIApplication.shared.canOpenURL(telURL) {
            UIApplication.shared.open(telURL)
        } else if let telURL = URL(string: telScheme) {
            // Fallback for environments where canOpenURL returns false (e.g., Simulator)
            UIApplication.shared.open(telURL)
        }
    }
}
