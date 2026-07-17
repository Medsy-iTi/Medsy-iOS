//
//  LanguageManager.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Foundation
import Observation
import UIKit

@Observable
final class LanguageManager {
    static let shared = LanguageManager()

    private enum Keys {
        static let selectedLanguage = "pharmacy_selected_language"
    }

    private(set) var currentLanguage: PharmacyAppLanguage {
        didSet {
            persist(currentLanguage)
            PharmacyBundleLanguage.setLanguage(currentLanguage.rawValue)
            applyUIKitDirection(currentLanguage)
        }
    }

    var isRTL: Bool {
        currentLanguage.isRTL
    }

    var languageCode: String {
        currentLanguage.rawValue
    }

    private init() {
        if let saved = UserDefaults.standard.string(forKey: Keys.selectedLanguage),
           let language = PharmacyAppLanguage(rawValue: saved) {
            currentLanguage = language
        } else {
            currentLanguage = .arabic
        }

        PharmacyBundleLanguage.setLanguage(currentLanguage.rawValue)
        applyUIKitDirection(currentLanguage)
    }

    func set(_ language: PharmacyAppLanguage) {
        guard language != currentLanguage else { return }
        currentLanguage = language
    }

    func toggle() {
        currentLanguage = currentLanguage.toggled
    }

    private func persist(_ language: PharmacyAppLanguage) {
        UserDefaults.standard.set(language.rawValue, forKey: Keys.selectedLanguage)
    }

    private func applyUIKitDirection(_ language: PharmacyAppLanguage) {
        let attribute: UISemanticContentAttribute = language.isRTL
            ? .forceRightToLeft
            : .forceLeftToRight
        UIView.appearance().semanticContentAttribute = attribute
        UINavigationBar.appearance().semanticContentAttribute = attribute
        UITabBar.appearance().semanticContentAttribute = attribute
        UITableView.appearance().semanticContentAttribute = attribute
    }
}
