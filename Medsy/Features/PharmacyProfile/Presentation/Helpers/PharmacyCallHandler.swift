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

        #if targetEnvironment(simulator)
        print("📱 [Simulator Mode] Dialing pharmacy: \(phoneNumber) (\(cleaned))")
        let alert = UIAlertController(
            title: "pharmacyProfile.call".localized,
            message: "\(phoneNumber)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            rootVC.present(alert, animated: true)
        }
        #else
        let promptScheme = "telprompt://\(cleaned)"
        let telScheme = "tel://\(cleaned)"

        if let promptURL = URL(string: promptScheme), UIApplication.shared.canOpenURL(promptURL) {
            UIApplication.shared.open(promptURL)
        } else if let telURL = URL(string: telScheme), UIApplication.shared.canOpenURL(telURL) {
            UIApplication.shared.open(telURL)
        }
        #endif
    }
}
