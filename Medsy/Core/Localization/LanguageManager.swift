//
//  LanguageManager.swift
//  Medsy
//
//  Created by Ahmed Elkady on 13/07/2026.
//

import Foundation
import Observation
import UIKit

@Observable
final class LanguageManager {


    static let shared = LanguageManager()


    private enum Keys {
        static let selectedLanguage = "app_selected_language"
    }

    private(set) var currentLanguage: AppLanguage {
        didSet {
            persist(currentLanguage)
            BundleLanguage.setLanguage(currentLanguage.rawValue)
            applyUIKitDirection(currentLanguage)
        }
    }

    var isRTL: Bool { currentLanguage.isRTL }

    var languageCode: String { currentLanguage.rawValue }

   
    private init() {
        if let saved = UserDefaults.standard.string(forKey: Keys.selectedLanguage),
           let language = AppLanguage(rawValue: saved) {
            currentLanguage = language
        } else {
            currentLanguage = .arabic
        }

        BundleLanguage.setLanguage(currentLanguage.rawValue)
        applyUIKitDirection(currentLanguage)
    }

   
    func set(_ language: AppLanguage) {
        guard language != currentLanguage else { return }
        currentLanguage = language
    }

    func toggle() {
        currentLanguage = currentLanguage.toggled
    }

 
    private func persist(_ language: AppLanguage) {
        UserDefaults.standard.set(language.rawValue, forKey: Keys.selectedLanguage)
    }

    private func applyUIKitDirection(_ language: AppLanguage) {
        let attribute: UISemanticContentAttribute = language.isRTL
            ? .forceRightToLeft
            : .forceLeftToRight
        UIView.appearance().semanticContentAttribute = attribute
        UINavigationBar.appearance().semanticContentAttribute = attribute
        UITabBar.appearance().semanticContentAttribute = attribute
        UITableView.appearance().semanticContentAttribute = attribute
    }
}
